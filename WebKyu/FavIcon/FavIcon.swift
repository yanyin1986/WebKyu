//
// FavIcon
// Copyright © 2016 Leon Breedt
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

#if os(iOS)
    import UIKit
    /// Alias for the iOS image type (`UIImage`).
    public typealias ImageType = UIImage
#elseif os(OSX)
    import Cocoa
    /// Alias for the OS X image type (`NSImage`).
    public typealias ImageType = NSImage
#endif

/// Represents the result of attempting to download an icon.
public enum IconDownloadResult {

    /// Download successful.
    ///
    /// - parameter image: The `ImageType` for the downloaded icon.
    case success(image: ImageType)

    /// Download failed for some reason.
    ///
    /// - parameter error: The error which can be consulted to determine the root cause.
    case failure(error: Error)

}

/// Responsible for detecting all of the different icons supported by a given site.
public final class FavIcon {

    // swiftlint:disable function_body_length

    /// Scans a base URL, attempting to determine all of the supported icons that can
    /// be used for favicon purposes.
    ///
    /// It will do the following to determine possible icons that can be used:
    ///
    /// - Check whether or not `/favicon.ico` exists.
    /// - If the base URL returns an HTML page, parse the `<head>` section and check for `<link>`
    ///   and `<meta>` tags that reference icons using Apple, Microsoft and Google
    ///   conventions.
    /// - If _Web Application Manifest JSON_ (`manifest.json`) files are referenced, or
    ///   _Microsoft browser configuration XML_ (`browserconfig.xml`) files
    ///   are referenced, download and parse them to check if they reference icons.
    ///
    ///  All of this work is performed in a background queue.
    ///
    /// - parameter url: The base URL to scan.
    /// - parameter completion: A closure to call when the scan has completed. The closure will be call
    ///                         on the main queue.
    public static func scan(_ url: URL, completion: @escaping ([DetectedIcon]) -> Void) {
        let queue = DispatchQueue(label: "org.bitserf.FavIcon", attributes: [])
        var icons: [DetectedIcon] = []
        var additionalDownloads: [URLRequestWithCallback] = []
        let urlSession = urlSessionProvider()

        let downloadHTMLOperation = DownloadTextOperation(url: url, session: urlSession)
        let downloadHTML = urlRequestOperation(downloadHTMLOperation) { result in
            if case let .textDownloaded(actualURL, text, contentType) = result {
                if contentType == "text/html" {
                    let document = HTMLDocument(string: text)

                    let htmlIcons = extractHTMLHeadIcons(document, baseURL: actualURL)
                    queue.sync {
                        icons.append(contentsOf: htmlIcons)
                    }

                    for manifestURL in extractWebAppManifestURLs(document, baseURL: url) {
                        let downloadOperation = DownloadTextOperation(url: manifestURL,
                                                                              session: urlSession)
                        let download = urlRequestOperation(downloadOperation) { result in
                            if case .textDownloaded(_, let manifestJSON, _) = result {
                                let jsonIcons = extractManifestJSONIcons(
                                    manifestJSON,
                                    baseURL: actualURL
                                )
                                queue.sync {
                                    icons.append(contentsOf: jsonIcons)
                                }
                            }
                        }
                        additionalDownloads.append(download)
                    }

                    let browserConfigResult = extractBrowserConfigURL(document, baseURL: url)
                    if let browserConfigURL = browserConfigResult.url, !browserConfigResult.disabled {
                        let downloadOperation = DownloadTextOperation(url: browserConfigURL,
                                                                      session: urlSession)
                        let download = urlRequestOperation(downloadOperation) { result in
                            if case let .textDownloaded(_, browserConfigXML, _) = result {
                                let document = LBXMLDocument(string: browserConfigXML)
                                let xmlIcons = extractBrowserConfigXMLIcons(
                                    document,
                                    baseURL: actualURL
                                )
                                queue.sync {
                                    icons.append(contentsOf: xmlIcons)
                                }
                            }
                        }
                        additionalDownloads.append(download)
                    }
                }
            }
        }


        let favIconURL = URL(string: "/favicon.ico", relativeTo: url as URL)!.absoluteURL
        let checkFavIconOperation = CheckURLExistsOperation(url: favIconURL, session: urlSession)
        let checkFavIcon = urlRequestOperation(checkFavIconOperation) { result in
            if case let .success(actualURL) = result {
                queue.sync {
                    icons.append(DetectedIcon(url: actualURL, type: .classic))
                }
            }
        }

        executeURLOperations([downloadHTML, checkFavIcon]) {
            if additionalDownloads.count > 0 {
                executeURLOperations(additionalDownloads) {
                    DispatchQueue.main.async {
                        completion(icons)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(icons)
                }
            }
        }
    }
    // swiftlint:enable function_body_length

    /// Downloads an array of detected icons in the background.
    ///
    /// - parameter icons: The icons to download.
    /// - parameter completion: A closure to call when all download tasks have
    ///                         results available (successful or otherwise). The closure
    ///                         will be called on the main queue.
    public static func download(_ icons: [DetectedIcon], completion: @escaping ([IconDownloadResult]) -> Void) {
        let urlSession = urlSessionProvider()
        let operations: [DownloadImageOperation] =
            icons.map { DownloadImageOperation(url: $0.url, session: urlSession) }

        executeURLOperations(operations) { results in
            let downloadResults: [IconDownloadResult] = results.map { result in
                switch result {
                case .imageDownloaded(_, let image):
                    return IconDownloadResult.success(image: image)
                case .failed(let error):
                    return IconDownloadResult.failure(error: error)
                default:
                    return IconDownloadResult.failure(error: IconError.invalidDownloadResponse)
                }
            }

            DispatchQueue.main.async {
                completion(downloadResults)
            }
        }
    }

    /// Downloads all available icons by calling `scan(url:)` to discover the available icons, and then
    /// performing background downloads of each icon.
    ///
    /// - parameter url: The URL to scan for icons.
    /// - parameter completion: A closure to call when all download tasks have results available
    ///                         (successful or otherwise). The closure will be called on the main queue.
    public static func downloadAll(_ url: URL, completion: @escaping ([IconDownloadResult]) -> Void) {
        scan(url) { icons in
            download(icons, completion: completion)
        }
    }

    /// Downloads the most preferred icon, by calling `scan(url:)` to discover available icons, and then choosing
    /// the most preferable available icon. If both `width` and `height` are supplied, the icon closest to the
    /// preferred size is chosen. Otherwise, the largest icon is chosen, if dimensions are known. If no icon
    /// has dimensions, the icons are chosen by order of their `DetectedIconType` enumeration raw value.
    ///
    /// - parameter url: The URL to scan for icons.
    /// - parameter width: The preferred icon width, in pixels, or `nil`.
    /// - parameter height: The preferred icon height, in pixels, or `nil`.
    /// - parameter completion: A closure to call when the download task has produced results. The closure will
    ///                         be called on the main queue.
    /// - throws: An appropriate `IconError` if downloading was not successful.
    public static func downloadPreferred(_ url: URL,
                                         width: Int? = nil,
                                         height: Int? = nil,
                                         completion: @escaping (IconDownloadResult) -> Void) throws {
        scan(url) { icons in
            guard let icon = chooseIcon(icons, width: width, height: height) else {
                DispatchQueue.main.async {
                    completion(IconDownloadResult.failure(error: IconError.noIconsDetected))
                }
                return
            }

            let urlSession = urlSessionProvider()

            print(icon.url)
            let operations = [DownloadImageOperation(url: icon.url, session: urlSession)]
            executeURLOperations(operations) { results in
                let downloadResults: [IconDownloadResult] = results.map { result in
                    switch result {
                    case let .imageDownloaded(_, image):
                        return IconDownloadResult.success(image: image)
                    case let .failed(error):
                        return IconDownloadResult.failure(error: error)
                    default:
                        return IconDownloadResult.failure(error: IconError.invalidDownloadResponse)
                    }
                }

                assert(downloadResults.count > 0)

                DispatchQueue.main.async {
                    completion(downloadResults.first!)
                }
            }
        }
    }

    // MARK: Test hooks

    typealias URLSessionProvider = (Void) -> URLSession
    static var urlSessionProvider: URLSessionProvider = FavIcon.createDefaultURLSession

    // MARK: Internal

    static func createDefaultURLSession() -> URLSession {
        return URLSession.shared
    }

    /// Helper function to choose an icon to use out of a set of available icons. If preferred
    /// width or height is supplied, the icon closest to the preferred size is chosen. If no
    /// preferred width or height is supplied, the largest icon (if known) is chosen.
    ///
    /// - parameter icons: The icons to choose from.
    /// - parameter width: The preferred icon width.
    /// - parameter height: The preferred icon height.
    /// - returns: The chosen icon, or `nil`, if `icons` is empty.
    static func chooseIcon(_ icons: [DetectedIcon], width: Int? = nil, height: Int? = nil) -> DetectedIcon? {
        guard icons.count > 0 else { return nil }

        let iconsInPreferredOrder = icons.sorted { left, right in
            if let preferredWidth = width, let preferredHeight = height,
               let widthLeft = left.width, let heightLeft = left.height,
               let widthRight = right.width, let heightRight = right.height {
                // Which is closest to preferred size?
                let deltaA = abs(widthLeft - preferredWidth) * abs(heightLeft - preferredHeight)
                let deltaB = abs(widthRight - preferredWidth) * abs(heightRight - preferredHeight)
                return deltaA < deltaB
            } else {
                if let areaLeft = left.area, let areaRight = right.area {
                    // Which is larger?
                    return areaRight < areaLeft
                }
            }

            if left.area != nil {
                // Only A has dimensions, prefer it.
                return true
            }
            if right.area != nil {
                // Only B has dimensions, prefer it.
                return false
            }

            // Neither has dimensions, order by enum value
            return left.type.rawValue < right.type.rawValue
        }

        return iconsInPreferredOrder.first!
    }

    fileprivate init () {
    }
}

/// Enumerates errors that can be thrown while detecting or downloading icons.
enum IconError: Error {
    /// The base URL specified is not a valid URL.
    case invalidBaseURL
    /// At least one icon to must be specified for downloading.
    case atLeastOneOneIconRequired
    /// Unexpected response when downloading
    case invalidDownloadResponse
    /// No icons were detected, so nothing could be downloaded.
    case noIconsDetected
}

extension FavIcon {
    /// Convenience overload for `scan(url:completion:)` that takes a `String`
    /// instead of a `URL` as the URL parameter. Throws an error if the URL is not a valid URL.
    ///
    /// - parameter url: The base URL to scan.
    /// - parameter completion: A closure to call when the scan has completed. The closure will be called
    ///                         on the main queue.
    /// - throws: An `IconError` if the scan failed for some reason.
    public static func scan(_ url: String, completion: @escaping ([DetectedIcon]) -> Void) throws {
        guard let url = URL(string: url) else { throw IconError.invalidBaseURL }
        scan(url, completion: completion)
    }

    /// Convenience overload for `downloadAll(url:completion:)` that takes a `String`
    /// instead of a `URL` as the URL parameter. Throws an error if the URL is not a valid URL.
    ///
    /// - parameter url: The URL to scan for icons.
    /// - parameter completion: A closure to call when all download tasks have results available
    ///                         (successful or otherwise). The closure will be called on the main queue.
    /// - throws: An `IconError` if the scan or download failed for some reason.
    public static func downloadAll(_ url: String, completion: @escaping ([IconDownloadResult]) -> Void) throws {
        guard let url = URL(string: url) else { throw IconError.invalidBaseURL }
        downloadAll(url, completion: completion)
    }

    /// Convenience overload for `downloadPreferred(url:width:height:completion:)` that takes a `String`
    /// instead of a `URL` as the URL parameter. Throws an error if the URL is not a valid URL.
    ///
    /// - parameter url: The URL to scan for icons.
    /// - parameter width: The preferred icon width, in pixels, or `nil`.
    /// - parameter height: The preferred icon height, in pixels, or `nil`.
    /// - parameter completion: A closure to call when the download task has produced a result. The closure will
    ///                         be called on the main queue.
    /// - throws: An appropriate `IconError` if downloading failed for some reason.
    public static func downloadPreferred(_ url: String,
                                         width: Int? = nil,
                                         height: Int? = nil,
                                         completion: @escaping (IconDownloadResult) -> Void) throws {
        guard let url = URL(string: url) else { throw IconError.invalidBaseURL }
        try downloadPreferred(url, width: width, height: height, completion: completion)
    }
}

extension DetectedIcon {
    /// The area of a detected icon, if known.
    var area: Int? {
        if let width = width, let height = height {
            return width * height
        }
        return nil
    }
}

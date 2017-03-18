//
//  MDURLProtocol.swift
//  WebKyu
//
//  Created by yan on 2017/02/28.
//  Copyright © 2017 mmd. All rights reserved.
//

import Foundation
import Kingfisher
import ImageIO

let MDURLProtocolKey: String = "mmd.dev.mdurlprotocol"

enum TrackRequirable {
    case checkLater
    case no
    case yes
}

final class MDURLProtocol: URLProtocol, URLSessionDataDelegate {
    
    private var _dataTask: URLSessionDataTask?
    private var _data: Data?
    private var _shouldCache: Bool = false
    private var _mimeType: MimeType = MimeType.unknow
    private var _trackRequirable = TrackRequirable.checkLater
    private var _cookie = HTTPCookieStorage.shared
    private var needTrackMimeType = [
        "image",
        "video",
    ]
    private let unTrackMimeType = [
        "text",
        "application",
        "multipart",
    ]
    
    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url,
              let scheme = url.scheme else {
            return false
        }
        
        guard URLProtocol.property(forKey: MDURLProtocolKey, in: request) == nil else {
            return false
        }
        
        if (scheme == "http" || scheme == "https")
            && url.pathExtension != ""
            && !url.path.hasSuffix("css") && !url.path.hasSuffix("js") && !url.path.hasSuffix("woff") {
            print("\(url), \(url.pathExtension)")
            return true
        }
        return false
    }
    
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        print("start Loading: \(self.request)")
        if let request = self.request as? NSMutableURLRequest {
            URLProtocol.setProperty(true, forKey: MDURLProtocolKey, in: request)
        }
        
        if let url = request.url?.pathExtension,
            url == "mp4" {
            print(request)
        }
        
        let imageCache = MDStoreage.shared.imageCache()
        let cacheResult = imageCache.isImageCached(forKey: request.url!.absoluteString)
        if cacheResult.cached {
            let path = imageCache.cachePath(forKey: request.url!.absoluteString)
            print(path)
            do {
                let data = try Data.init(contentsOf: URL(fileURLWithPath: path))
                self.client?.urlProtocol(self, didLoad: data)
            } catch {
                self.client?.urlProtocol(self, didFailWithError: error)
            }
            self.client?.urlProtocolDidFinishLoading(self)
        } else {
            let configuration = URLSessionConfiguration.default;
            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            _dataTask = session.dataTask(with: self.request)
            _dataTask?.resume()
        }
    }
    
    override func stopLoading() {
        _dataTask?.cancel()
        _dataTask = nil
        _data = nil
    }
    
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let mimeType = response.mimeType {
            _mimeType = mimeType.mimeType
            
            if _trackRequirable == .checkLater {
                for type in needTrackMimeType {
                    if mimeType.hasPrefix(type) {
                        _trackRequirable = .yes
                        
                        if type == "video" && response.url != nil {
                            Global.share.videos.append(response.url!)
                        }
                        
                        break
                    }
                }
            }
            
            if _trackRequirable == .checkLater {
                for type in unTrackMimeType {
                    if mimeType.hasPrefix(type) {
                        _trackRequirable = .no
                        break
                    }
                }
            }
        }
        self.client?.urlProtocol(self,
                                 didReceive: response,
                                 cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if _data == nil {
            _data = Data()
            let mimeType = data.mimeType
            if mimeType != MimeType.unknow {
                _trackRequirable = .yes
            } else {
                _trackRequirable = .no
            }
        }
        _data!.append(data)
        self.client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let err = error as? URLError, err.code != .cancelled {
            self.client?.urlProtocol(self, didFailWithError: err)
        } else {
            if _trackRequirable == .yes && _data != nil {
                let imageCache = MDStoreage.shared.imageCache()
                imageCache.store(DefaultCacheSerializer.default.image(with: _data!, options: nil)!,
                                 original: _data,
                                 forKey: task.currentRequest!.url!.absoluteString,
                                 toDisk: true, completionHandler: nil)
                guard let source = CGImageSourceCreateWithData(_data! as CFData, nil) else {
                    return
                }
                
                let options = [ kCGImageSourceShouldCache as String : false] as CFDictionary
                
                guard let properties =
                    CGImageSourceCopyPropertiesAtIndex(source, 0, options) as? NSDictionary else {
                    return
                }
                
                var size: CGSize = CGSize(width: -1, height: -1)
                
                if let width = properties[kCGImagePropertyPixelWidth as String] as? NSNumber {
                    size.width = CGFloat(width.doubleValue)
                }
                
                if let height = properties[kCGImagePropertyPixelHeight as String] as? NSNumber {
                    size.height = CGFloat(height.doubleValue)
                }
                
                let image = Image(url: task.currentRequest!.url!,
                                  cacheKey: task.currentRequest!.url!.absoluteString,
                                  mimeType: _mimeType,
                                  size: size,
                                  fileLength: Int64(_data!.count))
                Global.share.add(image: image)
            }
        }
        
        _data = nil
        self.client?.urlProtocolDidFinishLoading(self)
    }
}

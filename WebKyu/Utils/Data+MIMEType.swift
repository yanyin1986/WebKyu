//
//  Data+MIMEType.swift
//  WebKyu
//
//  Created by yan on 2017/03/01.
//  Copyright © 2017 mmd. All rights reserved.
//

import Foundation

struct MimeType: OptionSet {
    let rawValue: Int
    
    static let jpeg = MimeType(rawValue: 1 << 0)
    static let png  = MimeType(rawValue: 1 << 1)
    static let gif  = MimeType(rawValue: 1 << 2)
    static let tiff = MimeType(rawValue: 1 << 3)
    static let webp = MimeType(rawValue: 1 << 4)
    static let unknow = MimeType(rawValue: 1 << 32)
    
    static let all: MimeType = [.jpeg, .png, .gif, .tiff, .webp]
}

extension Data {
    var mimeType: MimeType {
        // analyse data type with bytes
        var value: UInt8 = 0
        self.copyBytes(to: &value, count: 1)
        
        var mimeType: MimeType = MimeType.unknow
        switch value {
        case 0xFF:
            mimeType = MimeType.jpeg
        case 0x89:
            mimeType = MimeType.png
        case 0x47:
            mimeType = MimeType.gif
        case 0x49, 0x4D:
            mimeType = MimeType.tiff
        case 0x52:
            if self.count > 12 {
                if let testString = String(data: self.subdata(in: 0 ..< 12), encoding: .ascii) {
                    if (testString.hasPrefix("RIFF") && testString.hasSuffix("WEBP")) {
                        mimeType = MimeType.webp
                    }
                }
            }
        default:
            mimeType = MimeType.unknow
        }
        return mimeType
    }
}

extension String {
    var mimeType: MimeType {
        switch self {
        case "image/jpg", "image/jpeg":
            return MimeType.jpeg
        case "image/png":
            return MimeType.png
        case "image/gif":
            return MimeType.gif
        case "image/tiff":
            return MimeType.tiff
        case "image/webp":
            return MimeType.webp
        default:
            return MimeType.unknow
        }
    }
}

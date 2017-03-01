//
//  Image.swift
//  WebKyu
//
//  Created by yan on 2017/03/01.
//  Copyright © 2017 mmd. All rights reserved.
//

import Foundation
import UIKit

struct Image: Hashable {
    var mimeType: MimeType
    var url: URL
    var cacheKey: String
    var fileLength: Int64
    var size: CGSize
    
    init(url: URL, cacheKey: String, mimeType: MimeType, size: CGSize, fileLength: Int64) {
        self.url = url
        self.cacheKey = cacheKey
        self.mimeType = mimeType
        self.size = size
        self.fileLength = fileLength
    }
    
    var hashValue: Int {
        return self.cacheKey.hashValue
    }
    
    public static func ==(lhs: Image, rhs: Image) -> Bool {
        return lhs.cacheKey == rhs.cacheKey && lhs.mimeType == rhs.mimeType
            && lhs.url == rhs.url && lhs.size.equalTo(rhs.size)
            && lhs.fileLength == rhs.fileLength
    }
}

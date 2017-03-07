//
//  Storeage.swift
//  WebKyu
//
//  Created by yan on 2017/02/28.
//  Copyright © 2017 mmd. All rights reserved.
//

import Foundation
import Kingfisher


let appGroupId = "group.mmd.webpuppy"

protocol Storeage: class {
    func imageCache() -> ImageCache
}

final class MDStoreage: Storeage {
    static let shared: Storeage = MDStoreage()
    private var _shareContainerUrl: URL
    
    private var _imageCache: ImageCache?
    func imageCache() -> ImageCache {
        if _imageCache == nil {
            _imageCache = ImageCache(name: appGroupId,
                                     path: _shareContainerUrl.path)
        }
        return _imageCache!
    }
    
    init() {
        if let shareContainerUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) {
            _shareContainerUrl = shareContainerUrl
            print(_shareContainerUrl)
        } else {
            fatalError("init share container url failed")
        }
    }
}

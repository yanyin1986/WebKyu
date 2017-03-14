//
//  Storeage.swift
//  WebKyu
//
//  Created by yan on 2017/02/28.
//  Copyright © 2017 mmd. All rights reserved.
//

import Foundation
import Kingfisher
import SQLite


let appGroupId = "group.mmd.webpuppy"

protocol Storeage: class {
    func imageCache() -> ImageCache
    func db() -> Connection
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
    
    private var _db: Connection?
    func db() -> Connection {
        if _db == nil {
            let path = _shareContainerUrl.appendingPathComponent("sqlite.db")
            do {
                _db = try Connection(path.path)
                
                let imageTable = Table("imageCache")
                try _db!.run(imageTable.create(ifNotExists: true, block: { (t) in
                    t.column(Expression<Int64>("id"), primaryKey: PrimaryKey.autoincrement)
                    t.column(Expression<String>("url"), unique: true)
                    t.column(Expression<String>("path"))
                    t.column(Expression<String>("type"))
                    t.column(Expression<Double>("width"))
                    t.column(Expression<Double>("height"))
                    t.column(Expression<Double>("file_length"))
                    t.column(Expression<Bool>("collected"))
                    t.column(Expression<String>("album"))
                }))
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        
        return _db!
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

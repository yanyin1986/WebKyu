//
//  BookmarkManager.swift
//  WebKyu
//
//  Created by Leon.yan on 25/06/2017.
//  Copyright © 2017 mmd. All rights reserved.
//

import Foundation

class Bookmark: NSObject, NSCoding {
    let url: URL
    let favIconUrl: URL?

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(url, forKey: "url")
        aCoder.encode(favIconUrl, forKey: "favIconUrl")
    }

    public init(url: URL, favIconUrl: URL? = nil) {
        self.url = url
        self.favIconUrl = favIconUrl
    }

    public required init?(coder aDecoder: NSCoder) {
        if let url = aDecoder.decodeObject(forKey: "url") as? URL {
            self.url = url
        } else {
            fatalError("error when decode")
        }

        if let favIconUrl = aDecoder.decodeObject(forKey: "favIconUrl") as? URL {
            self.favIconUrl = favIconUrl
        } else {
            self.favIconUrl = nil
        }
    }

    public static func ==(lhs: Bookmark, rhs: Bookmark) -> Bool {
        return lhs.url == rhs.url
    }
}

extension UserDefaults {
    func setArchiveValue(_ value: Any?, forKey key: String) {
        guard let v = value else { return }
        self.setValue(NSKeyedArchiver.archivedData(withRootObject: v), forKey: key)
    }

    open func unarvhivedValue(forKey key: String) -> Any? {
        guard let data = value(forKey: key) as? Data else { return  nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data)
    }
    
}

class BookmarkManager: NSObject {

    var bookmarks: [Bookmark] = [] {
        didSet {
            UserDefaults.standard.setArchiveValue(bookmarks, forKey: "bookmarks")
            UserDefaults.standard.synchronize()
        }
    }

    static let shared: BookmarkManager = BookmarkManager()
    
    override init() {
        UserDefaults.standard.register(defaults: [
            "bookmarks" : NSKeyedArchiver.archivedData(withRootObject: [
                Bookmark(url: URL(string: "http://instagram.com")!,
                         favIconUrl: URL(string: "https://www.instagram.com/static/images/ico/apple-touch-icon-180x180-precomposed.png/94fd767f257b.png")),
                Bookmark(url: URL(string: "http://pinterest.com")!,
                         favIconUrl: URL(string: "https://s.pinimg.com/images/favicon_red_192.png")),
                Bookmark(url: URL(string: "http://500px.com")!,
                         favIconUrl: URL(string: "https://assetcdn.500px.org/assets/favicon-7d8942fba5c5649f91a595d0fc749c83.ico")),
                Bookmark(url: URL(string: "http://flickr.com")!,
                         favIconUrl: URL(string: "https://s.yimg.com/pw/images/favicon-msapplication-tileimage.png")),
                Bookmark(url: URL(string: "http://tumblr.com")!,
                         favIconUrl: URL(string: "https://assets.tumblr.com/images/apple-touch-icon-228x228.png?_v=3cb4fe24e7a5c4cdb91b813509dd8f53")),
                ])
            ])

        if let array = UserDefaults.standard.unarvhivedValue(forKey: "bookmarks") as? [Bookmark] {
            bookmarks = array
        }
    }
}



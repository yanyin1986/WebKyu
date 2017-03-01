//
//  Global.swift
//  WebKyu
//
//  Created by yan on 2017/03/01.
//  Copyright © 2017 mmd. All rights reserved.
//

import Foundation
import CoreGraphics

typealias FilterOption = [FilterOptionItem]

enum FilterOptionItem {
    case resolution(CGSize, CGSize)
    case fileSize(Int64)
    case mimeType(MimeType)
}

precedencegroup ItemComparisonPrecedence {
    associativity: none
    higherThan: LogicalConjunctionPrecedence
}

infix operator <==: ItemComparisonPrecedence

func <==(lhs: FilterOptionItem, rhs: FilterOptionItem) -> Bool {
    switch (lhs, rhs) {
    case (.resolution(_), .resolution(_)): return true
    case (.fileSize(_), .fileSize(_)): return true
    case (.mimeType(_), .mimeType(_)): return true
    default: return false
    }
}

extension Sequence where Iterator.Element == FilterOptionItem {
    func a() {
        
    }
}

final class Global {
    static let share: Global = Global()
    private var _images: [Image] = []
    private var _imageSet: Set<Image> = Set()
    private init() {
        
    }
    
    func contains(image: Image) -> Bool {
        return _imageSet.contains(image)
    }
    
    /// add image, and return image index
    ///
    /// - Parameter image: image
    /// - Returns: -1 when failed, image index when success
    @discardableResult
    func add(image: Image) -> Int {
        var result = -1
        if (_imageSet.insert(image).inserted) {
            result = _images.count
            _images.append(image)
        }
        return result
    }
    
    func images(withFilterOptions options: FilterOption? = nil) -> [Image] {
        guard let opts = options else { return _images }
        
        var images = _images
        for item in opts {
            if item <== FilterOptionItem.resolution(CGSize.zero, CGSize.zero),
                case FilterOptionItem.resolution(let minSize, let maxSize) = item {
                images = images.filter{
                    (minSize.width > 0 ? $0.size.width > minSize.width : true)
                        && (minSize.height > 0 ? $0.size.height > minSize.height : true)
                        && (maxSize.width > 0 ? $0.size.width < maxSize.width : true)
                        && (maxSize.height > 0 ? $0.size.height < maxSize.height : true)
                }
            } else if item <== FilterOptionItem.mimeType(MimeType.unknow),
                case FilterOptionItem.mimeType(let mimeType) = item {
                images = images.filter{ $0.mimeType == mimeType }
            } else if item <== FilterOptionItem.fileSize(0),
                case FilterOptionItem.fileSize(let fileSize) = item {
                images = images.filter { $0.fileLength < fileSize }
            }
        }
        
        return images
    }
    
    
}

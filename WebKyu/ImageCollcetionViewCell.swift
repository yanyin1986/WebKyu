//
//  ImageCollcetionViewCell.swift
//  WebKyu
//
//  Created by yan on 2017/03/01.
//  Copyright © 2017 mmd. All rights reserved.
//

import UIKit
import YYImage

class ImageCollcetionViewCell: UICollectionViewCell {
    @IBOutlet
    weak var imageView: YYAnimatedImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.runloopMode = RunLoopMode.defaultRunLoopMode.rawValue
    }
}

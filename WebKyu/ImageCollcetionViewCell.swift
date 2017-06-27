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
        self.backgroundColor = UIColor(red: 0xee/255.0, green: 0xee/255.0, blue: 0xee/255.0, alpha: 1.0)
        imageView.runloopMode = RunLoopMode.defaultRunLoopMode.rawValue
    }
}

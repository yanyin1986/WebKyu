//
//  BookmarkCollectionViewCell.swift
//  WebKyu
//
//  Created by Leon.yan on 26/06/2017.
//  Copyright © 2017 mmd. All rights reserved.
//

import UIKit

class BookmarkCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowOffset = CGSize.zero
    }
}

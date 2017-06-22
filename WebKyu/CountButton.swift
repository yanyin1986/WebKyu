//
//  CountButton.swift
//  WebKyu
//
//  Created by Leon.yan on 07/03/2017.
//  Copyright © 2017 mmd. All rights reserved.
//

import UIKit

private let unselectColor = UIColor.gray
private let selectedColor = UIColor.red

class CountButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.isEnabled = false
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.size.min / 2.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.size.min / 2.0
    }
    
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = isEnabled ? selectedColor : unselectColor
        }
    }
    
}

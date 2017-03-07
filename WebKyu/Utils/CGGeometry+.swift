//
//  CGGeometry+.swift
//  WebKyu
//
//  Created by Leon.yan on 07/03/2017.
//  Copyright © 2017 mmd. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGSize {
    var min: CGFloat {
        get {
            return self.width > self.height ? self.height : self.width
        }
    }
     
}

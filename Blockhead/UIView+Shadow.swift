//
//  UIView+Shadow.swift
//  Blockhead
//
//  Created by Christoph on 7/9/20.
//  Copyright © 2020 Hermiteer, LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    var shadowIsEnabled: Bool {
        get {
            return self.layer.shadowOpacity > 0.0
        }
        set {
            self.layer.shadowColor = UIColor.black.cgColor
//            self.layer.shadowOffset = CGSize.zero
            self.layer.shadowOpacity = 1.0//0.5
            self.layer.shadowRadius = 10
        }
    }
}

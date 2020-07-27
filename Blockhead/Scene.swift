//
//  Scene.swift
//  Blockhead
//
//  Created by Christoph on 7/27/20.
//  Copyright © 2020 Hermiteer, LLC. All rights reserved.
//

import Foundation
import UIKit

class Scene {
    var hudViewIsHidden = false
    var boxOpacity: Amount = .full
    var faceOpacity: Amount = .none
    var screenOpacity: Amount = .none
    var pixellateAmount: Amount = .none
    var lights: Amount = .some
    var textureImage: CGImage? = nil
}

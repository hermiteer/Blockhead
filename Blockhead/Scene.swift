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

    enum UntrackedBehaviour: Int, CaseIterable {

//        case drift
//        case dropAndBump
        case drop
        case float
        case random  // this must always be last

        // Returns a random case EXCEPT for the last "random" case.
        static func random() -> UntrackedBehaviour {
            guard UntrackedBehaviour.allCases.count > 1 else { return .drift }
            let count = UntrackedBehaviour.allCases.count - 1
            let value = Int.random(in: 0..<count)
            return UntrackedBehaviour(rawValue: value) ?? .drift
        }
    }

    var hudViewIsHidden = false
    var boxOpacity: Amount = .full
    var faceOpacity: Amount = .none
    var screenOpacity: Amount = .none
    var pixellateAmount: Amount = .none
    var lights: Amount = .some
    var boxTexture: CGImage? = nil
    var untrackedBehaviour: UntrackedBehaviour = .random

    func currentUntrackedBehaviour() -> UntrackedBehaviour {
        switch self.untrackedBehaviour {
            case .random:   return UntrackedBehaviour.random()
            default:        return self.untrackedBehaviour
        }
    }
}

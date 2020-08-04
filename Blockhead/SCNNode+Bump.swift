//
//  SCNNode+Bump.swift
//  Blockhead
//
//  Created by Christoph on 8/3/20.
//  Copyright © 2020 Hermiteer, LLC. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {

    var isBumping: Bool {
        return self.actionKeys.contains("bump") || self.actionKeys.contains("waitThenBumpForever")
    }

    func bumpAction() -> SCNAction {
        return SCNAction.run() {
            node in
            guard let body = node.physicsBody else { return }
            let x = Float.random(in: -0.5..<0.5)
            let y = Float.random(in: 1.0..<1.5)
            let z = Float.random(in: -0.5..<0.5)
            let force = SCNVector3(x, y, z)
            body.applyForce(force, asImpulse: true)
        }
    }

    func bump() {
        self.runAction(self.bumpAction(), forKey: "bump")
    }

    func bumpForever(_ interval: TimeInterval) {
        let wait = SCNAction.wait(duration: interval)
        let waitThenBump = SCNAction.sequence([wait, self.bumpAction()])
        let waitThenBumpForever = SCNAction.repeatForever(waitThenBump)
        self.runAction(waitThenBumpForever, forKey: "waitThenBumpForever")
    }
}

//
//  SCNNode+Drift.swift
//  Blockhead
//
//  Created by Christoph on 8/3/20.
//  Copyright © 2020 Hermiteer, LLC. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {

    var isDrifting: Bool {
        return self.actionKeys.contains("drift") || self.actionKeys.contains("waitThenDriftForever")
    }

    func driftAction() -> SCNAction {
        return SCNAction.run() {
            node in
            guard let body = node.physicsBody else { return }
            let x = Float.random(in: -0.1..<0.1)
            let y = Float.random(in: -0.1..<0.1)
            let z = Float.random(in: -0.1..<0.1)
            let force = SCNVector3(x, y, z)
            body.applyForce(force, asImpulse: true)
        }
    }

    func drift() {
        self.runAction(self.driftAction())
    }

    func driftForever(_ interval: TimeInterval) {
        let wait = SCNAction.wait(duration: interval)
        let waitThenDrift = SCNAction.sequence([wait, self.driftAction()])
        let waitThenDriftForever = SCNAction.repeatForever(waitThenDrift)
        self.runAction(waitThenDriftForever)
    }
}

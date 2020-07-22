//
//  SCNVector3+Blockhead.swift
//  Blockhead
//
//  Created by Christoph on 7/22/20.
//  Copyright © 2020 Hermiteer, LLC. All rights reserved.
//

import Foundation
import SceneKit

extension SCNVector3 {

    static func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(x: lhs.x + rhs.x,
                          y: lhs.y + rhs.y,
                          z: lhs.z + rhs.z)
    }

    static func -(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(x: lhs.x - rhs.x,
                          y: lhs.y - rhs.y,
                          z: lhs.z - rhs.z)
    }
}

extension Array where Element == SCNVector3 {

    // TODO fixed limit?
    mutating func add(_ vector: SCNVector3) {
        self.insert(vector, at: 0)
        if self.count > 10 { self.removeLast() }
    }

    func sum() -> SCNVector3 {
        var result = SCNVector3Zero
        self.forEach { result = result + $0 }
        return result
    }
}

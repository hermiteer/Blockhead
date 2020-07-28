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

    static func distanceFrom(vector vector1: SCNVector3,
                             toVector vector2: SCNVector3) -> Float
    {
        let x0 = vector1.x
        let x1 = vector2.x
        let y0 = vector1.y
        let y1 = vector2.y
        let z0 = vector1.z
        let z1 = vector2.z
        return sqrtf(powf(x1-x0, 2) + powf(y1-y0, 2) + powf(z1-z0, 2))
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

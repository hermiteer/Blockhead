//
//  SCNVector4+Blockhead.swift
//  Blockhead
//
//  Created by Christoph on 7/22/20.
//  Copyright © 2020 Hermiteer, LLC. All rights reserved.
//

import Foundation
import SceneKit

extension SCNVector4 {

    static func +(lhs: SCNVector4, rhs: SCNVector4) -> SCNVector4 {
        return SCNVector4(x: lhs.x + rhs.x,
                          y: lhs.y + rhs.y,
                          z: lhs.z + rhs.z,
                          w: lhs.w + rhs.w)
    }

    static func -(lhs: SCNVector4, rhs: SCNVector4) -> SCNVector4 {
        return SCNVector4(x: lhs.x - rhs.x,
                          y: lhs.y - rhs.y,
                          z: lhs.z - rhs.z,
                          w: lhs.w - rhs.w)
    }
}

extension Array where Element == SCNVector4 {

    // TODO fixed limit?
    mutating func add(_ vector: SCNVector4) {
        self.insert(vector, at: 0)
        if self.count > 10 { self.removeLast() }
    }

    func sum() -> SCNVector4 {
        var result = SCNVector4Zero
        self.forEach { result = result + $0 }
        return result
    }
}

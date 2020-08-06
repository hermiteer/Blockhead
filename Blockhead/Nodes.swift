//
//  Nodes.swift
//  Blockhead
//
//  Created by Christoph on 8/6/20.
//  Copyright © 2020 Hermiteer, LLC. All rights reserved.
//

import Foundation
import SceneKit

struct Nodes {

    static func wallNode() -> SCNNode {
        let plane = SCNPlane(width: 2, height: 1)
//        plane.firstMaterial?.colorBufferWriteMask = SCNColorMask.alpha
        plane.firstMaterial?.diffuse.contents = UIColor.red
        let node = SCNNode(geometry: plane)
        node.position = SCNVector3(0, 0, -2)
        node.physicsBody = SCNPhysicsBody.static()
        return node
    }

    static func floorNode() -> SCNNode {
        let plane = SCNPlane(width: 2, height: 2)
//        plane.firstMaterial?.colorBufferWriteMask = SCNColorMask.alpha
        plane.firstMaterial?.diffuse.contents = UIColor.red
        let node = SCNNode(geometry: plane)
        node.position = SCNVector3(0, -0.25, -1)
        node.rotation = SCNVector4(1, 0, 0, Double.pi / -2)
        node.physicsBody = SCNPhysicsBody.static()
        return node
    }
}

//
//  BlockheadTests.swift
//  BlockheadTests
//
//  Created by Christoph on 7/27/20.
//  Copyright © 2020 Hermiteer, LLC. All rights reserved.
//

import XCTest

class BlockheadTests: XCTestCase {

    func test_nextSceneIndexDoesNotRepeat() {
        var index = 0
        for _ in 1...1000 {
            let next = Scenes.shared.nextSceneIndex()
            XCTAssertTrue(index != next)
            index = next
        }
    }
}

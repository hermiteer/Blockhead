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

    func test_bpm() {

        // 60 bpm
        XCTAssertTrue(TimeInterval(.quarterNote) == 1.0)

        // 120 bpm
        XCTAssertTrue(TimeInterval(.quarterNote, bpm: 120) == 0.5)
        XCTAssertTrue(TimeInterval(.halfNote, bpm: 120) == 1.0)
        XCTAssertTrue(TimeInterval(.wholeNote, bpm: 120) == 2.0)

        // 130 bpm
        // this is hard to compare and may break in the future
        // depending on how many decimal places are supported
        // by the compiler's language
        XCTAssertTrue(TimeInterval(.quarterNote, bpm: 130) == 0.46153846153846156)
    }
}

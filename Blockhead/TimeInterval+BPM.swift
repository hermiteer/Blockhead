//
//  TimeInterval+BPM.swift
//  Blockhead
//
//  Created by Christoph on 8/3/20.
//  Copyright © 2020 Hermiteer, LLC. All rights reserved.
//

import Foundation

extension TimeInterval {

    enum NoteLength: Double {
        case thirtySecondNote = 0.125
        case sixteenthNote = 0.25
        case eighthNote = 0.5
        case quarterNote = 1.0
        case halfNote = 2.0
        case wholeNote = 4.0
    }

    init(_ length: NoteLength, bpm: Double = 60.0) {
        let value = (60.0 / bpm) * length.rawValue
        self.init(value)
    }
}

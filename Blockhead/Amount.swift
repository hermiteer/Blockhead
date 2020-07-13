//
//  Amount.swift
//  Blockhead
//
//  Created by Christoph on 7/13/20.
//  Copyright © 2020 Hermiteer, LLC. All rights reserved.
//

import Foundation
import UIKit

enum Amount: CaseIterable {

    case full
    case some
    case none

    var floatValue: CGFloat {
        switch self {
            case .full: return 1.0
            case .some: return 0.5
            default: return 0.0
        }
    }

    var next: Amount {
        let cases = Amount.allCases
        if self == cases.last { return cases[0] }
        if let index = cases.firstIndex(of: self) { return cases[index + 1] }
        return cases[0]
    }

    var title: String {
        switch self {
            case .full: return "Full"
            case .some: return "Some"
            default: return "None"
        }
    }
}

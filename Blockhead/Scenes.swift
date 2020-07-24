//
//  Scenes.swift
//  Blockhead
//
//  Created by Christoph on 7/24/20.
//  Copyright © 2020 Hermiteer, LLC. All rights reserved.
//

import Foundation
import UIKit

class Scenes: NSObject {

    // MARK: Lifecycle

    static let shared = Scenes()

    // TODO this is ugly
    // TODO protocol?
    weak var controller: ViewController?

    // MARK: Timer

    var isSwitchingScenes = false {
        didSet {
            if isSwitchingScenes {
                Timer.scheduledTimer(withTimeInterval: 99, repeats: true) {
                    timer in
                    // TODO invalidate timer when turned off?
                    guard self.isSwitchingScenes else { return }
                    self.switchScenes()
                }
            }
        }
    }

    // MARK: Scenes

    private var scenes = [
        #selector(blockyFace),
//        #selector(chunkyFace),
//        #selector(clearFace),
        #selector(threeDegrees),
//        #selector(ripe),
        #selector(rumblemunk),
//        #selector(rumblemunkChunky),
        #selector(sanrio),
//        #selector(sanrioChunky)
    ]

    private var sceneIndexes: [Int] = []

    // TODO do not switch same scene twice
    private func switchScenes() {

        // reset indexes if needed
        if self.sceneIndexes.count == self.scenes.count {
            self.sceneIndexes = []
        }

        // select the next scene
        var index = self.scenes.randomIndex()
        while self.sceneIndexes.contains(index) {
            index = self.scenes.randomIndex()
        }

        // perform the scene
        let scene = self.scenes[index]
        self.perform(scene)
    }

    @objc
    private func blockyFace() {
        guard let controller = self.controller else { return }
        controller.pixellateAmount = .full
    }

    @objc
    private func chunkyFace() {
        guard let controller = self.controller else { return }
        controller.pixellateAmount = .some
    }

    @objc
    private func clearFace() {
        guard let controller = self.controller else { return }
        controller.pixellateAmount = .none
    }

    @objc
    private func rumblemunk() {
        guard let controller = self.controller else { return }
        controller.pixellateAmount = .none
        controller.textureImage = UIImage(named: "Rumblemunk")?.cgImage
    }

    @objc
    private func rumblemunkChunky() {
        guard let controller = self.controller else { return }
        controller.pixellateAmount = .some
        controller.textureImage = UIImage(named: "Rumblemunk")?.cgImage
    }

    @objc
    private func ripe() {
        guard let controller = self.controller else { return }
        controller.pixellateAmount = .none
        controller.textureImage = UIImage(named: "RIPE")?.cgImage
    }

    @objc
    private func sanrio() {
        guard let controller = self.controller else { return }
        controller.pixellateAmount = .none
        controller.textureImage = UIImage(named: "Sanrio")?.cgImage
    }

    @objc
    private func sanrioChunky() {
        guard let controller = self.controller else { return }
        controller.pixellateAmount = .some
        controller.textureImage = UIImage(named: "Sanrio")?.cgImage
    }

    @objc
    private func threeDegrees() {
        guard let controller = self.controller else { return }
        controller.pixellateAmount = .none
        controller.textureImage = UIImage(named: "3degrees")?.cgImage
    }
}

fileprivate extension Array {

    func randomIndex() -> Int {
        return Int(arc4random() % UInt32(self.count))
    }
}

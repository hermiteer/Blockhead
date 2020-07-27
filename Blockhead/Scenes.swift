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
                Timer.scheduledTimer(withTimeInterval: 14.72, repeats: true) {
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
//        #selector(none),
//        #selector(blockyFace),
//        #selector(chunkyFace),
        #selector(clearFace),
//        #selector(ripe),
        #selector(rumblemunkFull),
//        #selector(rumblemunkSome),
        #selector(sanrioFull),
//        #selector(sanrioSome),
        #selector(threeDegreesFull),
        #selector(threeDegreesSome),
    ]

    private var sceneIndexes: [Int] = []

    func nextSceneIndex() -> Int {

        // reset indexes if needed
        // keep last one added so next is always different
        if self.sceneIndexes.count == self.scenes.count {
            let count = self.sceneIndexes.count - 1
            self.sceneIndexes.removeFirst(count)
        }

        // select the next scene
        var index = self.scenes.randomIndex()
        while self.sceneIndexes.contains(index) {
            index = self.scenes.randomIndex()
        }

        // remember that scene
        self.sceneIndexes += [index]
        return index
    }

    private func switchScenes() {
        let index = self.nextSceneIndex()
        let scene = self.scenes[index]
        self.perform(scene)
    }

    @objc
    private func none() {
        guard let controller = self.controller else { return }
        controller.boxOpacity = .none
        controller.pixellateAmount = .none
        controller.textureImage = nil
    }

    @objc
    private func blockyFace() {
        guard let controller = self.controller else { return }
        controller.boxOpacity = .full
        controller.pixellateAmount = .full
        controller.textureImage = nil
    }

    @objc
    private func chunkyFace() {
        guard let controller = self.controller else { return }
        controller.boxOpacity = .full
        controller.pixellateAmount = .some
        controller.textureImage = nil
    }

    @objc
    private func clearFace() {
        guard let controller = self.controller else { return }
        controller.boxOpacity = .full
        controller.pixellateAmount = .none
        controller.textureImage = nil
    }

    @objc
    private func rumblemunkFull() {
        guard let controller = self.controller else { return }
        controller.boxOpacity = .full
        controller.pixellateAmount = .none
        controller.textureImage = UIImage(named: "Rumblemunk")?.cgImage
    }

    @objc
    private func rumblemunkSome() {
        guard let controller = self.controller else { return }
        controller.boxOpacity = .some
        controller.pixellateAmount = .none
        controller.textureImage = UIImage(named: "Rumblemunk")?.cgImage
    }

    @objc
    private func ripe() {
        guard let controller = self.controller else { return }
        controller.pixellateAmount = .none
        controller.textureImage = UIImage(named: "RIPE")?.cgImage
    }

    @objc
    private func sanrioFull() {
        guard let controller = self.controller else { return }
        controller.boxOpacity = .full
        controller.pixellateAmount = .none
        controller.textureImage = UIImage(named: "Sanrio")?.cgImage
    }

    @objc
    private func sanrioSome() {
        guard let controller = self.controller else { return }
        controller.boxOpacity = .some
        controller.pixellateAmount = .none
        controller.textureImage = UIImage(named: "Rumblemunk")?.cgImage
    }

    @objc
    private func threeDegreesFull() {
        guard let controller = self.controller else { return }
        controller.boxOpacity = .full
        controller.pixellateAmount = .none
        controller.textureImage = UIImage(named: "3degrees")?.cgImage
    }

    @objc
    private func threeDegreesSome() {
        guard let controller = self.controller else { return }
        controller.boxOpacity = .full
        controller.pixellateAmount = .none
        controller.textureImage = UIImage(named: "3degrees-hole")?.cgImage
    }
}

fileprivate extension Array {

    func randomIndex() -> Int {
        return Int(arc4random() % UInt32(self.count))
    }
}

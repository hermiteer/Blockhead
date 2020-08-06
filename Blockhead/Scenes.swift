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
                Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) {
                    timer in
                    self.isSwitchingScenes ? self.switchScenes() : timer.invalidate()
                }
            }
        }
    }

    // MARK: Scene switching

    internal lazy var scenes = [
        none(),
        blockyFace(),
        chunkyFace(),
        face(),
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

    func switchScenes() {
        guard self.scenes.count > 1 else { return }
        let index = self.nextSceneIndex()
        let scene = self.scenes[index]
        self.controller?.scene = scene
    }

    // MARK: Default scenes

    private func none() -> Scene {
        let scene = Scene()
        scene.boxOpacity = .none
        scene.pixellateAmount = .none
        return scene
    }

    private func blockyFace() -> Scene {
        let scene = Scene()
        scene.boxOpacity = .full
        scene.pixellateAmount = .full
        return scene
    }

    private func chunkyFace() -> Scene {
        let scene = Scene()
        scene.boxOpacity = .full
        scene.pixellateAmount = .some
        return scene
    }

    private func face() -> Scene {
        let scene = Scene()
        scene.boxOpacity = .full
        scene.pixellateAmount = .none
        return scene
    }
}

fileprivate extension Array {

    func randomIndex() -> Int {
        return Int(arc4random() % UInt32(self.count))
    }
}

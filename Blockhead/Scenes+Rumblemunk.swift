//
//  Scenes+Rumblemunk.swift
//  Blockhead
//
//  Created by Christoph on 7/27/20.
//  Copyright © 2020 Hermiteer, LLC. All rights reserved.
//

import Foundation
import UIKit

extension Scenes {

    func addRumblemunkScenes() {
        self.scenes += [rumblemunkFull()]
        self.scenes += [rumblemunkSome()]
        self.scenes += [ripe()]
        self.scenes += [sanrioFull()]
        self.scenes += [sanrioSome()]
        self.scenes += [threeDegreesFull()]
        self.scenes += [threeDegreesSome()]
    }

    private func rumblemunkFull() -> Scene {
        let scene = Scene()
        scene.boxOpacity = .full
        scene.pixellateAmount = .none
        scene.textureImage = UIImage(named: "Rumblemunk")?.cgImage
        return scene
    }

    private func rumblemunkSome() -> Scene {
        let scene = Scene()
        scene.boxOpacity = .some
        scene.pixellateAmount = .none
        scene.textureImage = UIImage(named: "Rumblemunk")?.cgImage
        return scene
    }

    private func ripe() -> Scene {
        let scene = Scene()
        scene.pixellateAmount = .none
        scene.textureImage = UIImage(named: "RIPE")?.cgImage
        return scene
    }

    private func sanrioFull() -> Scene {
        let scene = Scene()
        scene.boxOpacity = .full
        scene.pixellateAmount = .none
        scene.textureImage = UIImage(named: "Sanrio")?.cgImage
        return scene
    }

    private func sanrioSome() -> Scene {
        let scene = Scene()
        scene.boxOpacity = .some
        scene.pixellateAmount = .none
        scene.textureImage = UIImage(named: "Rumblemunk")?.cgImage
        return scene
    }

    private func threeDegreesFull() -> Scene {
        let scene = Scene()
        scene.boxOpacity = .full
        scene.pixellateAmount = .none
        scene.textureImage = UIImage(named: "3degrees")?.cgImage
        return scene
    }

    private func threeDegreesSome() -> Scene {
        let scene = Scene()
        scene.boxOpacity = .full
        scene.pixellateAmount = .none
        scene.textureImage = UIImage(named: "3degrees-hole")?.cgImage
        return scene
    }
}

//
//  ViewController.swift
//  Life Saver
//
//  Created by Bradley Root on 5/18/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Cocoa
import GameplayKit
import SpriteKit

class ViewController: NSViewController {
    @IBOutlet var skView: SKView!

    private var lifeScene: LifeScene?

    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = LifeScene(size: view.frame.size)
        lifeScene = scene

        scene.animationSpeed = .fastest
        scene.squareSize = .ultraSmall
        scene.deathFade = false
        scene.shiftingColors = true
        scene.startPaused = true  // Pause after first generation

        if let preset = settingsPresets.filter({ $0.title == "Technicolor Dream" }).first {
            if let appearanceMode = preset.appearanceMode {
                scene.appearanceMode = appearanceMode
            }
            if let color1 = preset.color1, let color2 = preset.color2, let color3 = preset.color3 {
                scene.aliveColors = [color1, color2, color3]
            }
        }

        let skView = view as? SKView
//        skView?.preferredFramesPerSecond = 60
        skView?.presentScene(scene)
        skView?.showsFPS = true
        skView?.showsDrawCount = true
        skView?.showsNodeCount = true

        skView?.ignoresSiblingOrder = true
    }

}

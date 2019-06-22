//
//  GameViewController.swift
//  Life Saver tvOS
//
//  Created by Bradley Root on 5/19/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import GameplayKit
import SpriteKit
import UIKit

class GameViewController: UIViewController {
    var scene: LifeScene?
    var skView: SKView?

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isIdleTimerDisabled = true
        view = SKView(frame: UIScreen.main.bounds)
        scene = LifeScene(size: view.bounds.size)

        scene!.animationSpeed = .fast
        scene!.squareSize = .superSmall

        if let preset = lifePresets.filter({ $0.title == "Braineater" }).first {
            if let appearanceMode = preset.appearanceMode {
                scene!.appearanceMode = appearanceMode
            }
            if let color1 = preset.color1, let color2 = preset.color2, let color3 = preset.color3 {
                scene!.aliveColors = [color1, color2, color3]
            }
        }

        scene!.scaleMode = .aspectFill
        skView = view as? SKView
        skView?.ignoresSiblingOrder = true
        skView?.showsFPS = true
        skView?.showsDrawCount = true
        skView?.showsNodeCount = true
        skView!.presentScene(scene)
    }
}

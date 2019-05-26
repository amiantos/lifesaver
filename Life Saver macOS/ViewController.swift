//
//  ViewController.swift
//  Life Saver
//
//  Created by Bradley Root on 5/18/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Cocoa
import GameplayKit
import SpriteKit

class ViewController: NSViewController {
    @IBOutlet var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = LifeScene(size: view.frame.size)


        scene.animationSpeed = .fast
        scene.squareSize = .medium

        if let preset = lifePresets.filter({ $0.title == "Georgia" }).first {
            if let appearanceMode = preset.appearanceMode {
                scene.appearanceMode = appearanceMode
            }
            if let color1 = preset.color1, let color2 = preset.color2, let color3 = preset.color3 {
                scene.aliveColors = [color1, color2, color3]
            }
        }


        let skView = view as? SKView
        skView?.presentScene(scene)

        skView?.ignoresSiblingOrder = true
    }
}

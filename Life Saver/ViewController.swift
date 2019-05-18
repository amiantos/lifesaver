//
//  ViewController.swift
//  Life Saver
//
//  Created by Bradley Root on 5/18/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = LifeScene(size: view.bounds.size)

        let skView = view as? SKView
        skView?.presentScene(scene)

        skView?.ignoresSiblingOrder = true
        skView?.showsDrawCount = true
        skView?.showsFPS = true
        skView?.showsNodeCount = true
    }
}


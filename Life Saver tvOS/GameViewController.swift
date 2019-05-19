//
//  GameViewController.swift
//  Life Saver tvOS
//
//  Created by Bradley Root on 5/19/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    var scene: LifeScene?
    var skView: SKView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        view = SKView(frame: UIScreen.main.bounds)
        scene = LifeScene(size: view.bounds.size)
        scene!.scaleMode = .aspectFill

        skView = view as? SKView
        skView?.ignoresSiblingOrder = true
        skView?.showsFPS = false
        skView!.presentScene(scene)
    }

}

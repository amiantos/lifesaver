//
//  LifeScene.swift
//  Life Saver
//
//  Created by Bradley Root on 5/18/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import GameplayKit
import SpriteKit

class LifeScene: SKScene {

    private var cameraNode: SKCameraNode = SKCameraNode()

    override func sceneDidLoad() {
        size.width = frame.size.width * 2
        size.height = frame.size.height * 2
        backgroundColor = SKColor.white
    }

    override func didMove(to _: SKView) {

    }

    override func update(_ currentTime: TimeInterval) {
        print(currentTime)
    }

}

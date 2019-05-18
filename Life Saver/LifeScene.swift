//
//  LifeScene.swift
//  Life Saver
//
//  Created by Bradley Root on 5/18/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import GameplayKit
import SpriteKit

class LifeScene: SKScene, SKPhysicsContactDelegate {

    private var cameraNode: SKCameraNode = SKCameraNode()

    override func sceneDidLoad() {
        size.width = frame.size.width * 2
        size.height = frame.size.height * 2
        backgroundColor = SKColor.white

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
//        physicsBody?.categoryBitMask = CollisionTypes.edge.rawValue
        physicsBody?.friction = 0
    }

    override func didMove(to _: SKView) {
        physicsWorld.contactDelegate = self
    }

    override func update(_ currentTime: TimeInterval) {
        print(currentTime)
    }

}

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
    private var squareNodes: [SKShapeNode] = []
    private var lastUpdate: TimeInterval = 0

    override func sceneDidLoad() {
        size.width = frame.size.width * 2
        size.height = frame.size.height * 2
        backgroundColor = SKColor.white

        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
        camera = cameraNode

        // Try drawing some squares...
        let lengthSquares: CGFloat = 25
        let heightSquares: CGFloat = 25
        let totalSquares: CGFloat = lengthSquares * heightSquares
        let squareWidth: CGFloat = size.width / lengthSquares
        let squareHeight: CGFloat = size.height / heightSquares

        var createdSquares: CGFloat = 0
        var nextXPosition: CGFloat = 0
        var nextYPosition: CGFloat = 0
        while createdSquares < totalSquares {
            let newSquare = SKShapeNode(rect: CGRect(x: 0, y: 0, width: squareWidth, height: squareHeight))
            newSquare.fillColor = .black
            addChild(newSquare)
            newSquare.position = CGPoint(x: nextXPosition, y: nextYPosition)
            let labelNode = SKLabelNode(text: "\(Int(createdSquares))")
            labelNode.fontColor = .white
            newSquare.addChild(labelNode)
            labelNode.position = CGPoint(x: squareWidth / 2, y: squareHeight / 2)

            createdSquares += 1
            squareNodes.append(newSquare)

            if createdSquares.truncatingRemainder(dividingBy: lengthSquares) == 0 {
                nextYPosition += squareHeight
            }
            if createdSquares.truncatingRemainder(dividingBy: heightSquares) == 0 {
                nextXPosition = 0
            } else {
                nextXPosition += squareWidth
            }
        }

    }

    override func didMove(to _: SKView) {

    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdate == 0 { lastUpdate = currentTime }
        if currentTime - lastUpdate >= 1 {
            let colors: [SKColor] = [
                .black,
                .blue,
                .brown,
                .green,
                .red,
                .purple,
                .white
            ]
            for child in squareNodes {
                print(child)
                child.fillColor = colors.randomElement()!
            }
            lastUpdate = currentTime
        }
    }

}

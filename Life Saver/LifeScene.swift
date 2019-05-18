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
            newSquare.strokeColor = .black
            addChild(newSquare)
            newSquare.position = CGPoint(x: nextXPosition, y: nextYPosition)
//            let labelNode = SKLabelNode(text: "\(Int(createdSquares))")
//            labelNode.fontColor = .white
//            newSquare.addChild(labelNode)
//            labelNode.position = CGPoint(x: squareWidth / 2, y: squareHeight / 2)

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
                SKColor(red: 2/255.0, green: 30/255.0, blue: 50/255.0, alpha: 1.00),
                SKColor(red: 173/255.0, green: 98/255.0, blue: 22/255.0, alpha: 1.00),
                SKColor(red: 14/255.0, green: 4/255.0, blue: 0/255.0, alpha: 1.00),
                SKColor(red: 14/255.0, green: 11/255.0, blue: 1/255.0, alpha: 1.00),
                SKColor(red: 14/255.0, green: 8/255.0, blue: 0/255.0, alpha: 1.00),
                SKColor(red: 0/255.0, green: 5/255.0, blue: 9/255.0, alpha: 1.00),
                SKColor(red: 3/255.0, green: 49/255.0, blue: 82/255.0, alpha: 1.00),
                SKColor(red: 172/255.0, green: 48/255.0, blue: 17/255.0, alpha: 1.00),
                SKColor(red: 174/255.0, green: 129/255.0, blue: 0/255.0, alpha: 1.00),
                SKColor(red: 80/255.0, green: 22/255.0, blue: 0/255.0, alpha: 1.00),
                SKColor(red: 80/255.0, green: 58/255.0, blue: 7/255.0, alpha: 1.00),
                SKColor(red: 79/255.0, green: 45/255.0, blue: 6/255.0, alpha: 1.00),
                SKColor(red: 128/255.0, green: 95/255.0, blue: 17/255.0, alpha: 1.00),
                SKColor(red: 6/255.0, green: 66/255.0, blue: 110/255.0, alpha: 1.00),
                SKColor(red: 129/255.0, green: 35/255.0, blue: 0/255.0, alpha: 1.00),
                SKColor(red: 128/255.0, green: 73/255.0, blue: 14/255.0, alpha: 1.00),
            ]
            for child in squareNodes {
                let color = colors.randomElement() ?? .black
                child.fillColor = color
                child.strokeColor = color
            }
            lastUpdate = currentTime
        }
    }

}

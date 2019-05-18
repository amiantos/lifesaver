//
//  LifeScene.swift
//  Life Saver
//
//  Created by Bradley Root on 5/18/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import GameplayKit
import SpriteKit

class SquareNodeData {
    let x: Int
    let y: Int
    let node: SKShapeNode
    var alive: Bool

    init(x: Int, y: Int, node: SKShapeNode, alive: Bool) {
        self.x = x
        self.y = y
        self.node = node
        self.alive = alive
    }
}

class LifeScene: SKScene {

    private var cameraNode: SKCameraNode = SKCameraNode()
    private var squareNodes: [SKShapeNode] = []
    private var lastUpdate: TimeInterval = 0

    private var squareData: [SquareNodeData] = []

    override func sceneDidLoad() {
        size.width = frame.size.width * 2
        size.height = frame.size.height * 2
        backgroundColor = SKColor.white

        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
        camera = cameraNode

        // Try drawing some squares...
        let lengthSquares: CGFloat = 10
        let heightSquares: CGFloat = 10
        let totalSquares: CGFloat = lengthSquares * heightSquares
        let squareWidth: CGFloat = size.width / lengthSquares
        let squareHeight: CGFloat = size.height / heightSquares

        var createdSquares: CGFloat = 0
        var nextXValue: Int = 0
        var nextYValue: Int = 0
        var nextXPosition: CGFloat = 0
        var nextYPosition: CGFloat = 0
        while createdSquares < totalSquares {
            let newSquare = SKShapeNode(rect: CGRect(x: 0, y: 0, width: squareWidth, height: squareHeight))
            newSquare.fillColor = .black
//            newSquare.strokeColor = .black
            addChild(newSquare)
            newSquare.position = CGPoint(x: nextXPosition, y: nextYPosition)
//            let labelNode = SKLabelNode(text: "\(Int(createdSquares))")
//            labelNode.fontColor = .white
//            newSquare.addChild(labelNode)
//            labelNode.position = CGPoint(x: squareWidth / 2, y: squareHeight / 2)

            let livingChoices = [true, false]
            let newSquareData = SquareNodeData(x: nextXValue, y: nextYValue, node: newSquare, alive: livingChoices.randomElement()!)
            if newSquareData.alive {
                newSquare.fillColor = SKColor(red: 173/255.0, green: 98/255.0, blue: 22/255.0, alpha: 1.00)
            }
            squareData.append(newSquareData)
//            labelNode.text = "(\(newSquareData.x), \(newSquareData.y))"

            createdSquares += 1
            squareNodes.append(newSquare)

            if nextXValue == Int(lengthSquares) - 1 {
                nextXValue = 0
                nextXPosition = 0
                nextYValue += 1
                nextYPosition += squareHeight
            } else {
                nextXValue += 1
                nextXPosition += squareWidth
            }

        }

    }

    override func didMove(to _: SKView) {

    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdate == 0 { lastUpdate = currentTime }
        if currentTime - lastUpdate >= 0.5 {
            let colors: [SKColor] = [
                SKColor(red: 173/255.0, green: 98/255.0, blue: 22/255.0, alpha: 1.00),
                SKColor(red: 172/255.0, green: 48/255.0, blue: 17/255.0, alpha: 1.00),
                SKColor(red: 174/255.0, green: 129/255.0, blue: 0/255.0, alpha: 1.00),
                SKColor(red: 80/255.0, green: 22/255.0, blue: 0/255.0, alpha: 1.00),
                SKColor(red: 80/255.0, green: 58/255.0, blue: 7/255.0, alpha: 1.00),
                SKColor(red: 79/255.0, green: 45/255.0, blue: 6/255.0, alpha: 1.00),
                SKColor(red: 128/255.0, green: 95/255.0, blue: 17/255.0, alpha: 1.00),
                SKColor(red: 129/255.0, green: 35/255.0, blue: 0/255.0, alpha: 1.00),
                SKColor(red: 128/255.0, green: 73/255.0, blue: 14/255.0, alpha: 1.00),
            ]

//            for _ in 0..<squareNodes.count / 10 {
//                let node = squareNodes.randomElement()!
//                let color = colors.randomElement() ?? .black
//                node.fillColor = color
////                node.strokeColor = color
//            }

            for nodeData in squareData {
                print("Current Node: (\(nodeData.x), \(nodeData.y))")

                // Get neighbors...
                let livingNeighbors = squareData.filter {
                    (($0.x == (nodeData.x + 1) && $0.y == (nodeData.y + 1))
                    || ($0.x == (nodeData.x - 1) && $0.y == (nodeData.y - 1))
                    || ($0.x == (nodeData.x + 1) && $0.y == (nodeData.y - 1))
                    || ($0.x == (nodeData.x - 1) && $0.y == (nodeData.y + 1))
                    || ($0.x == (nodeData.x) && $0.y == (nodeData.y + 1))
                    || ($0.x == (nodeData.x) && $0.y == (nodeData.y - 1))
                    || ($0.x == (nodeData.x - 1) && $0.y == (nodeData.y))
                    || ($0.x == (nodeData.x + 1) && $0.y == (nodeData.y)))
                    && $0.alive
                }

                if nodeData.alive {
                    if livingNeighbors.count > 3 {
                        nodeData.alive = false
                    } else if livingNeighbors.count < 2 {
                        nodeData.alive = false
                    }
                } else if livingNeighbors.count == 3 {
                    nodeData.alive = true
                }

                if nodeData.alive {
                    nodeData.node.fillColor = SKColor(red: 173/255.0, green: 98/255.0, blue: 22/255.0, alpha: 1.00)
                } else {
                    nodeData.node.fillColor = .black
                }
            }

            lastUpdate = currentTime
        }
    }

}

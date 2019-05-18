//
//  LifeScene.swift
//  Life Saver
//
//  Created by Bradley Root on 5/18/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import GameplayKit
import SpriteKit

extension SKColor {
    static let aliveColor = SKColor(red: 173/255.0, green: 98/255.0, blue: 22/255.0, alpha: 1.00)
    static let deadColor0 = SKColor(red: 128/255.0, green: 73/255.0, blue: 14/255.0, alpha: 1.00)
    static let deadColor1 = SKColor(red: 79/255.0, green: 45/255.0, blue: 6/255.0, alpha: 1.00)
    static let deadColor2 = SKColor(red: 39/255.0, green: 23/255.0, blue: 3/255.0, alpha: 1.00)
    static let deadColor3 = SKColor(red: 14/255.0, green: 8/255.0, blue: 0/255.0, alpha: 1.00)
}

class SquareNodeData {
    let x: Int
    let y: Int
    let node: SKShapeNode
    var alive: Bool
    var timeInState: Int = 0

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
        let lengthSquares: CGFloat = 20
        let heightSquares: CGFloat = 20
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
            newSquare.strokeColor = .black
            addChild(newSquare)
            newSquare.position = CGPoint(x: nextXPosition, y: nextYPosition)

            let livingChoices = [true, false]
            let newSquareData = SquareNodeData(x: nextXValue, y: nextYValue, node: newSquare, alive: livingChoices.randomElement()!)
            if newSquareData.alive {
                newSquare.fillColor = .aliveColor
                newSquare.strokeColor = .aliveColor
            }
            squareData.append(newSquareData)

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
        if currentTime - lastUpdate >= 0 {
            var dyingNodes: [SquareNodeData] = []
            var livingNodes: [SquareNodeData] = []
            for nodeData in squareData {
                print("Current Node: (\(nodeData.x), \(nodeData.y))")

                // Get neighbors...
                let livingNeighbors = squareData.filter {
                    let delta = (abs(nodeData.x - $0.x), abs(nodeData.y - $0.y))
                    switch (delta) {
                    case (1,1), (1,0), (0,1):
                        if $0.alive {
                            return true
                        } else {
                            return false
                        }
                    default:
                        return false
                    }
                }

                if nodeData.alive {
                    if livingNeighbors.count > 3 || livingNeighbors.count < 2 {
                        dyingNodes.append(nodeData)
                    }
                } else if livingNeighbors.count == 3 {
                    livingNodes.append(nodeData)
                } else {
                    dyingNodes.append(nodeData)
                }

            }

            while livingNodes.count < 10 {
                let nodeNumber = GKRandomSource.sharedRandom().nextInt(upperBound: dyingNodes.count)
                let node = dyingNodes[nodeNumber]
                livingNodes.append(node)
                dyingNodes.remove(at: nodeNumber)
            }

            livingNodes.forEach {
                if $0.alive {
                    $0.timeInState += 1
                } else {
                    $0.timeInState = 0
                }

                $0.alive = true

                $0.node.fillColor = .aliveColor
                $0.node.strokeColor = .aliveColor
            }

            dyingNodes.forEach {
                if !$0.alive {
                    $0.timeInState += 1
                } else {
                    $0.timeInState = 0
                }

                $0.alive = false

                var color: SKColor = .deadColor3
                switch $0.timeInState {
                case 0:
                    color = .deadColor0
                case 1:
                    color = .deadColor1
                default:
                    color = .deadColor3
                }

                $0.node.fillColor = color
                $0.node.strokeColor = color
            }

            lastUpdate = currentTime
        }
    }

}

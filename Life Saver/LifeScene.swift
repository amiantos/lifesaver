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
    static let aliveColor1 = SKColor(red: 174/255.0, green: 129/255.0, blue: 0/255.0, alpha: 1.00)
    static let aliveColor2 = SKColor(red: 172/255.0, green: 48/255.0, blue: 17/255.0, alpha: 1.00)
    static let aliveColor3 = SKColor(red: 6/255.0, green: 66/255.0, blue: 110/255.0, alpha: 1.00)

}

class SquareNodeData {
    let x: Int
    let y: Int
    let node: SKShapeNode
    var alive: Bool
    var timeInState: Int = 0
    var aliveColor: SKColor

    init(x: Int, y: Int, node: SKShapeNode, alive: Bool, aliveColor: SKColor) {
        self.x = x
        self.y = y
        self.node = node
        self.alive = alive
        self.aliveColor = aliveColor
    }
}

class LifeScene: SKScene {

    private var cameraNode: SKCameraNode = SKCameraNode()
    private var squareNodes: [SKShapeNode] = []
    private var lastUpdate: TimeInterval = 0

    private var squareData: [SquareNodeData] = []
    private var aliveSquareData: [SquareNodeData] = []
    private var deadSquareData: [SquareNodeData] = []

    private var aliveColors: [SKColor] = [.aliveColor, .aliveColor1, .aliveColor2, .aliveColor3]

    private var updateTime: TimeInterval = 1

    override func sceneDidLoad() {
        size.width = frame.size.width * 2
        size.height = frame.size.height * 2
        backgroundColor = SKColor.black

        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
        camera = cameraNode

        // Try drawing some squares...
        let lengthSquares: CGFloat = 15
        let heightSquares: CGFloat = 15
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
            newSquare.lineWidth = 0
            addChild(newSquare)
            newSquare.zPosition = 0
            newSquare.position = CGPoint(x: nextXPosition, y: nextYPosition)

            let livingChoices = [true, false]
            let aliveColor = aliveColors.randomElement()!
            let newSquareData = SquareNodeData(
                x: nextXValue,
                y: nextYValue,
                node: newSquare,
                alive: livingChoices.randomElement()!,
                aliveColor: aliveColor
            )
            if newSquareData.alive {
                let fadeAction = SKAction.fadeAlpha(to: 1, duration: updateTime)
                let colorAction = shapeColorChangeAction(from: .black, to: newSquareData.aliveColor, withDuration: updateTime)
                fadeAction.timingMode = .easeInEaseOut
                colorAction.timingMode = .easeInEaseOut
                newSquareData.node.run(fadeAction)
                newSquareData.node.run(colorAction)

                aliveSquareData.append(newSquareData)
            } else {
                deadSquareData.append(newSquareData)
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

        if currentTime - lastUpdate >= updateTime {
            var dyingNodes: [SquareNodeData] = []
            var livingNodes: [SquareNodeData] = []
            for nodeData in squareData {
                // Get neighbors...
                let livingNeighbors = aliveSquareData.filter {
                    let delta = (abs(nodeData.x - $0.x), abs(nodeData.y - $0.y))
                    switch (delta) {
                    case (1,1), (1,0), (0,1):
                        return true
                    default:
                        return false
                    }
                }

                if nodeData.alive {
                    if livingNeighbors.count > 3 || livingNeighbors.count < 2 {
                        dyingNodes.append(nodeData)
                    } else if nodeData.timeInState > 20 {
                        dyingNodes.append(nodeData)
                    } else {
                        livingNodes.append(nodeData)
                    }
                } else if livingNeighbors.count == 3 {
                    nodeData.aliveColor = livingNeighbors.randomElement()!.node.fillColor
                    livingNodes.append(nodeData)
                } else {
                    dyingNodes.append(nodeData)
                }

            }

            while CGFloat(livingNodes.count) < (CGFloat(squareData.count) * 0.08) {
                let nodeNumber = GKRandomSource.sharedRandom().nextInt(upperBound: dyingNodes.count)
                let node = dyingNodes[nodeNumber]
                node.aliveColor = aliveColors.randomElement()!
                livingNodes.append(node)
                dyingNodes.remove(at: nodeNumber)
            }

            livingNodes.forEach {
                if !$0.alive {
                    $0.timeInState = 0
                    $0.node.removeAllActions()
                    $0.alive = true
                    let fadeAction = SKAction.fadeAlpha(to: 1, duration: updateTime)
                    let colorAction = shapeColorChangeAction(from: $0.node.fillColor, to: $0.aliveColor, withDuration: updateTime)
                    fadeAction.timingMode = .easeInEaseOut
                    colorAction.timingMode = .easeInEaseOut
                    $0.node.run(fadeAction)
                    $0.node.run(colorAction)
                } else {
                    $0.timeInState += 1
                }
            }

            dyingNodes.forEach {
                if $0.alive {
                    $0.timeInState = 0
                    $0.node.removeAllActions()
                    $0.alive = false
                    let fadeAction = SKAction.fadeAlpha(to: 0.2, duration: updateTime * 5)
                    fadeAction.timingMode = .easeInEaseOut
                    $0.node.run(fadeAction)
                } else {
                    $0.timeInState += 1
                }
            }

            aliveSquareData = livingNodes
            deadSquareData = dyingNodes

            lastUpdate = currentTime
        }
    }

    func shapeColorChangeAction(from fromColor: SKColor, to toColor: SKColor, withDuration duration: TimeInterval) -> SKAction {

        func components(for color: SKColor) -> [CGFloat] {
            var comp = color.cgColor.components!
            // converts [white, alpha] to [red, green, blue, alpha]
            if comp.count < 4 {
                comp.insert(comp[0], at: 0)
                comp.insert(comp[0], at: 0)
            }
            return comp
        }
        func lerp(a: CGFloat, b: CGFloat, fraction: CGFloat) -> CGFloat {
            return (b-a) * fraction + a
        }

        let fromComp = components(for: fromColor)
        let toComp = components(for: toColor)
        let durationCGFloat = CGFloat(duration)
        return SKAction.customAction(withDuration: duration, actionBlock: { (node, elapsedTime) -> Void in
            let fraction = elapsedTime / durationCGFloat
            let transColor = SKColor(red: lerp(a: fromComp[0], b: toComp[0], fraction: fraction),
                                     green: lerp(a: fromComp[1], b: toComp[1], fraction: fraction),
                                     blue: lerp(a: fromComp[2], b: toComp[2], fraction: fraction),
                                     alpha: lerp(a: fromComp[3], b: toComp[3], fraction: fraction))
            (node as! SKShapeNode).fillColor = transColor
        })
    }

}


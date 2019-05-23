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
    // MARK: - Settings

    var aliveColors: [SKColor] = [
        SKColor.defaultColor1,
        SKColor.defaultColor2,
        SKColor.defaultColor3,
    ]

    var appearanceColor: SKColor = .black
    var appearanceMode: Appearance = .dark {
        didSet {
            switch appearanceMode {
            case .dark:
                appearanceColor = .black
            case .light:
                appearanceColor = .white
            }
        }
    }

    private var updateTime: TimeInterval = 1
    var animationSpeed: AnimationSpeed = .normal {
        didSet {
            switch animationSpeed {
            case .fast:
                updateTime = 0.5
            case .normal:
                updateTime = 2
            case .slow:
                updateTime = 5
            }
        }
    }

    var squareSize: SquareSize = .medium

    // MARK: - Scene Lifecycle

    override func sceneDidLoad() {
        size.width = frame.size.width * 2
        size.height = frame.size.height * 2
    }

    override func didMove(to _: SKView) {
        backgroundColor = appearanceColor
        scaleMode = .fill

        createLife()
    }

    private var lastUpdate: TimeInterval = 0

    override func update(_ currentTime: TimeInterval) {
        if lastUpdate == 0 {
            lastUpdate = currentTime
        }

        if currentTime - lastUpdate >= updateTime {
            lastUpdate = currentTime

            updateLife()
        }
    }

    // MARK: - Life Logic

    private var allNodes: [LifeNode] = []
    private var livingNodes: [LifeNode] = []
    private var deadNodes: [LifeNode] = []

    fileprivate func createLife() {
        var lengthSquares: CGFloat = 16
        var heightSquares: CGFloat = 9
        switch squareSize {
        case .large:
            lengthSquares = 7
            heightSquares = 4
        case .small:
            lengthSquares = 32
            heightSquares = 18
        default:
            break
        }

        let totalSquares: CGFloat = lengthSquares * heightSquares
        let squareWidth: CGFloat = size.width / lengthSquares
        let squareHeight: CGFloat = size.height / heightSquares

        var createdSquares: CGFloat = 0
        var nextXValue: Int = 0
        var nextYValue: Int = 0
        var nextXPosition: CGFloat = 0
        var nextYPosition: CGFloat = 0
        while createdSquares < totalSquares {
            let squarePosition = CGPoint(x: nextXPosition, y: nextYPosition)
            let squareRelativePosition = CGPoint(x: nextXValue, y: nextYValue)
            let squareSize = CGSize(width: squareWidth, height: squareHeight)

            let newSquare = LifeNode(
                relativePosition: squareRelativePosition,
                alive: Int.random(in: 0 ... 1) == 1 ? true : false,
                color: appearanceColor,
                size: squareSize
            )
            addChild(newSquare)
            newSquare.position = squarePosition

            if newSquare.alive {
                livingNodes.append(newSquare)
                newSquare.color = aliveColors.randomElement()!
            } else {
                deadNodes.append(newSquare)
            }
            allNodes.append(newSquare)

            createdSquares += 1

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

    fileprivate func updateLife() {
        var dyingNodes: [LifeNode] = []
        var livingNodes: [LifeNode] = []
        for nodeData in allNodes {
            // Get neighbors...
            let livingNeighbors = livingNodes.filter {
                let delta = (abs(nodeData.relativePosition.x - $0.relativePosition.x), abs(nodeData.relativePosition.y - $0.relativePosition.y))
                switch delta {
                case (1, 1), (1, 0), (0, 1):
                    return true
                default:
                    return false
                }
            }

            if nodeData.alive {
                if livingNeighbors.count > 3 || livingNeighbors.count < 2 {
                    dyingNodes.append(nodeData)
                } else if nodeData.timeInState > 10 {
                    dyingNodes.append(nodeData)
                } else {
                    livingNodes.append(nodeData)
                }
            } else if livingNeighbors.count == 3 {
                nodeData.aliveColor = livingNeighbors.randomElement()!.color
                livingNodes.append(nodeData)
            } else {
                dyingNodes.append(nodeData)
            }
        }

        // Fail-safe to ensure tank dieout doesn't happen
        while CGFloat(livingNodes.count) < (CGFloat(allNodes.count) * 0.08) {
            let nodeNumber = GKRandomSource.sharedRandom().nextInt(upperBound: dyingNodes.count)
            let node = dyingNodes[nodeNumber]
            node.aliveColor = aliveColors.randomElement()!
            livingNodes.append(node)
            dyingNodes.remove(at: nodeNumber)
        }

        // Update nodes here
        livingNodes.forEach {
            $0.live(duration: updateTime)
        }

        dyingNodes.forEach {
            $0.die(duration: updateTime * 5)
        }
        self.livingNodes = livingNodes
        deadNodes = dyingNodes
    }
}

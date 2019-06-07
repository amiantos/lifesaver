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

    private var updateTime: TimeInterval = 2
    var animationSpeed: AnimationSpeed = .normal {
        didSet {
            switch animationSpeed {
            case .fast:
                updateTime = 0.6
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
        if lastUpdate == 0 || currentTime - lastUpdate >= updateTime {
            lastUpdate = currentTime
            updateLife()
        }
    }

    // MARK: - Life Logic

    private var allNodes: [LifeNode] = []
    private var aliveNodes: [LifeNode] = []
    private var livingNodeHistory: [Int] = []
    private var lengthSquares: CGFloat = 16
    private var heightSquares: CGFloat = 9
    private var matrix: ToroidalMatrix<LifeNode> = ToroidalMatrix(rows: 0, columns: 0, defaultValue: LifeNode(relativePosition: .zero, alive: false, color: .black, size: .zero))

    fileprivate func createLife() {
        switch squareSize {
        case .large:
            lengthSquares = 7
            heightSquares = 4
        case .small:
            lengthSquares = 32
            heightSquares = 18
        case .verySmall:
            lengthSquares = 64
            heightSquares = 36
        case .superSmall:
            lengthSquares = 128
            heightSquares = 74
        default:
            break
        }

        matrix = ToroidalMatrix(rows: Int(lengthSquares), columns: Int(heightSquares), defaultValue: LifeNode(relativePosition: .zero, alive: false, color: .black, size: .zero))

        let totalSquares: CGFloat = lengthSquares * heightSquares
        let squareWidth: CGFloat = size.width / lengthSquares
        let squareHeight: CGFloat = size.height / heightSquares

        // Create Nodes
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
                alive: false,
                color: appearanceColor,
                size: squareSize
            )
            addChild(newSquare)
            newSquare.position = squarePosition

            if newSquare.alive {
                aliveNodes.append(newSquare)
                newSquare.color = aliveColors.randomElement()!
            }
            allNodes.append(newSquare)
            matrix[Int(squareRelativePosition.x), Int(squareRelativePosition.y)] = newSquare

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

        // Pre-fetch Neighbors
        for node in allNodes {
            var neighbors: [LifeNode] = []
            neighbors.append(matrix[Int(node.relativePosition.x - 1), Int(node.relativePosition.y)])
            neighbors.append(matrix[Int(node.relativePosition.x + 1), Int(node.relativePosition.y)])
            neighbors.append(matrix[Int(node.relativePosition.x), Int(node.relativePosition.y + 1)])
            neighbors.append(matrix[Int(node.relativePosition.x), Int(node.relativePosition.y - 1)])
            neighbors.append(matrix[Int(node.relativePosition.x + 1), Int(node.relativePosition.y + 1)])
            neighbors.append(matrix[Int(node.relativePosition.x - 1), Int(node.relativePosition.y - 1)])
            neighbors.append(matrix[Int(node.relativePosition.x - 1), Int(node.relativePosition.y + 1)])
            neighbors.append(matrix[Int(node.relativePosition.x + 1), Int(node.relativePosition.y - 1)])
            node.neighbors = neighbors
        }
    }

    fileprivate func updateLife() {
        var dyingNodes: [LifeNode] = []
        var livingNodes: [LifeNode] = []
        for node in allNodes {
            // Get living neighbors...
            let livingNeighbors = node.neighbors.filter { $0.alive }

            if node.alive {
                if livingNeighbors.count > 3 || livingNeighbors.count < 2 {
                    dyingNodes.append(node)
                } else {
                    livingNodes.append(node)
                }
            } else if livingNeighbors.count == 3 {
                node.aliveColor = livingNeighbors.randomElement()!.color
                livingNodes.append(node)
            } else {
                dyingNodes.append(node)
            }
        }

        // If entire tank is dead, generate a new tank!
        if CGFloat(livingNodes.count) == 0 {
            createRandomShapes(&dyingNodes, &livingNodes)
        }

        // Static tank prevention
        if livingNodeHistory.count >= 20 {
            livingNodeHistory.removeFirst()
            livingNodeHistory.append(livingNodes.count)
            if 1 ... 2 ~= Set(livingNodeHistory).count {
                dyingNodes.append(contentsOf: livingNodes)
                livingNodes.removeAll()
            }
        } else {
            livingNodeHistory.append(livingNodes.count)
        }

        // Update nodes here
        dyingNodes.forEach {
            $0.die(duration: updateTime * 5)
        }

        livingNodes.forEach {
            $0.live(duration: updateTime)
        }

        aliveNodes = livingNodes
    }

    fileprivate func createRandomShapes(_: inout [LifeNode], _ livingNodes: inout [LifeNode]) {
        var totalShapes: Int = 0
        switch squareSize {
        case .superSmall:
            totalShapes = 500
        case .verySmall:
            totalShapes = 50
        case .small:
            totalShapes = 20
        case .medium:
            totalShapes = 10
        case .large:
            totalShapes = 4
        }
        for _ in 1 ... totalShapes {
            let nodeNumber = GKRandomSource.sharedRandom().nextInt(upperBound: allNodes.count)
            let color = aliveColors.randomElement()!
            let node = allNodes[nodeNumber]
            for neighborNode in node.neighbors where Int.random(in: 0 ... 1) == 1 {
                neighborNode.aliveColor = color
                livingNodes.append(neighborNode)
            }
        }
    }
}

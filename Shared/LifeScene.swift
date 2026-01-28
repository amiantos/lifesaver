//
//  LifeScene.swift
//  Life Saver
//
//  Created by Bradley Root on 5/18/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import GameplayKit
import SpriteKit

final class LifeScene: SKScene, LifeManagerDelegate {
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

    var deathFade: Bool = true
    var shiftingColors: Bool = false

    private var animationTime: TimeInterval = 2
    private var updateTime: TimeInterval = 2
    var animationSpeed: AnimationSpeed = .normal {
        didSet {
            switch animationSpeed {
            case .fastest:
                animationTime = 0
                updateTime = 0
            case .fast:
                animationTime = 0.6
                updateTime = 0.6
            case .normal:
                animationTime = 2
                updateTime = 2
            case .slow:
                animationTime = 5
                updateTime = 5
            case .off:
                animationTime = 0
                updateTime = 0.1
            }
        }
    }

    var squareSize: SquareSize = .medium

    // MARK: - Manager

    var manager: LifeManager? {
        didSet {
            manager?.delegate = self
        }
    }

    func updatedSettings() {
        print("Updated Settings")
        isUpdating = false
        endLife()
        perform(#selector(createField), with: nil, afterDelay: 0.5)
    }

    // MARK: - Scene Lifecycle

    override func sceneDidLoad() {
        size.width = frame.size.width * 2
        size.height = frame.size.height * 2
        backgroundColor = .black
    }

    override func didMove(to _: SKView) {
        backgroundNode = SKSpriteNode(texture: squareTexture, color: appearanceColor, size: frame.size)
        backgroundNode.alpha = 0
        addChild(backgroundNode)
        backgroundNode.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        backgroundNode.zPosition = 0

        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        backgroundNode.run(fadeIn)

        createField()
    }

    private var lastUpdate: TimeInterval = 0

    private var isUpdating: Bool = true
    var startPaused: Bool = false
    private var hasRunFirstUpdate: Bool = false

    var isLifePaused: Bool {
        get { !isUpdating }
        set { isUpdating = !newValue }
    }

    func toggleLifePause() {
        isUpdating.toggle()
    }

    func stepOneGeneration() {
        updateLife()
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdate == 0 || currentTime - lastUpdate >= updateTime {
            lastUpdate = currentTime
            if isUpdating {
                updateLife()
                // If startPaused is set, pause after first update to show initial pattern
                if startPaused && !hasRunFirstUpdate {
                    hasRunFirstUpdate = true
                    isUpdating = false
                }
            }
        }
    }

    // MARK: - Life Parameters

    private var backgroundNode: SKSpriteNode = SKSpriteNode()
    private var allNodes: [LifeNode] = []
    private var aliveNodes: [LifeNode] = []
    private var activeCells: Set<LifeNode> = []
    private var historyBuffer: [Int] = Array(repeating: -1, count: 10)
    private var historyIndex: Int = 0
    private var historyFilled: Bool = false
    private var lengthSquares: CGFloat = 16
    private var heightSquares: CGFloat = 9
    private var matrix: ToroidalMatrix<LifeNode> = ToroidalMatrix(
        rows: 0,
        columns: 0,
        defaultValue: LifeNode(
            relativePosition: .zero,
            alive: false,
            color: .black,
            size: .zero
        )
    )

    // MARK: - Life Creation

    @objc func createField() {
        if let manager = manager {
            appearanceMode = manager.appearanceMode
            squareSize = manager.squareSize
            animationSpeed = manager.animationSpeed
            aliveColors = [manager.color1, manager.color2, manager.color3]
            deathFade = manager.deathFade
            shiftingColors = manager.shiftingColors
        }

        if backgroundNode.color != appearanceColor {
            let colorize = SKAction.colorize(with: appearanceColor, colorBlendFactor: 1.0, duration: 0.5)
            backgroundNode.run(colorize) {
                if !self.startPaused || !self.hasRunFirstUpdate {
                    self.isUpdating = true
                }
            }
        }

        scaleMode = .aspectFill

        switch squareSize {
        case .large:
            lengthSquares = 7
            heightSquares = 4
        case .medium:
            lengthSquares = 16
            heightSquares = 9
        case .small:
            lengthSquares = 32
            heightSquares = 18
        case .verySmall:
            lengthSquares = 64
            heightSquares = 36
        case .superSmall:
            lengthSquares = 128
            heightSquares = 74
        case .ultraSmall:
            lengthSquares = 256
            heightSquares = 148
        }

        createLife()
    }

    fileprivate func createLife() {
        matrix = ToroidalMatrix(
            rows: Int(lengthSquares),
            columns: Int(heightSquares),
            defaultValue: LifeNode(
                relativePosition: .zero,
                alive: false,
                color: .black,
                size: .zero
            )
        )

        let totalSquares: CGFloat = lengthSquares * heightSquares
        let squareWidth: CGFloat = size.width / lengthSquares
        let squareHeight: CGFloat = size.height / heightSquares

        // Create Nodes
        var nextXValue: Int = 0
        var nextYValue: Int = 0
        var nextXPosition: CGFloat = 0
        var nextYPosition: CGFloat = 0
        for _ in 1 ... Int(totalSquares) {
            let actualPosition = CGPoint(x: nextXPosition, y: nextYPosition)
            let relativePosition = CGPoint(x: nextXValue, y: nextYValue)
            let squareSize = CGSize(width: squareWidth, height: squareHeight)

            createLifeSquare(relativePosition, squareSize, actualPosition)

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
            createNeighbors(node)
        }
    }

    fileprivate func createLifeSquare(_ relativePosition: CGPoint, _ squareSize: CGSize, _ actualPosition: CGPoint) {
        let newSquare = LifeNode(
            relativePosition: relativePosition,
            alive: false,
            color: appearanceColor,
            size: squareSize
        )
        addChild(newSquare)
        newSquare.position = actualPosition
        newSquare.alpha = 0

        if newSquare.alive {
            aliveNodes.append(newSquare)
            newSquare.color = aliveColors.randomElement()!
        }
        allNodes.append(newSquare)
        matrix[Int(relativePosition.x), Int(relativePosition.y)] = newSquare
    }

    fileprivate func createNeighbors(_ node: LifeNode) {
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

    // MARK: - Life Ending

    fileprivate func destroyField() {
        removeAllChildren()
    }

    fileprivate func endLife() {
        allNodes.forEach { $0.remove(duration: 0.5) }
        allNodes.removeAll()
        aliveNodes.removeAll()
        activeCells.removeAll()
        historyBuffer = Array(repeating: -1, count: 10)
        historyIndex = 0
        historyFilled = false
    }

    // MARK: - Life Updates

    fileprivate func updateLife() {
        var dyingNodes: [LifeNode] = []
        var livingNodes: [LifeNode] = []
        var nextActiveCells: Set<LifeNode> = []

        // On first iteration or after reset, check all nodes
        // Otherwise, only check active cells (cells that changed or have neighbors that changed)
        let cellsToCheck: AnyCollection<LifeNode> = activeCells.isEmpty
            ? AnyCollection(allNodes)
            : AnyCollection(activeCells)

        for node in cellsToCheck {
            // Count living neighbors inline to avoid array allocation
            var livingNeighborCount = 0
            var sampleLivingNeighbor: LifeNode?
            for neighbor in node.neighbors where neighbor.alive {
                livingNeighborCount += 1
                if sampleLivingNeighbor == nil {
                    sampleLivingNeighbor = neighbor
                }
            }

            if node.alive {
                if livingNeighborCount > 3 || livingNeighborCount < 2 {
                    dyingNodes.append(node)
                    // Cell will change state - mark it and neighbors as active for next iteration
                    nextActiveCells.insert(node)
                    for neighbor in node.neighbors {
                        nextActiveCells.insert(neighbor)
                    }
                } else {
                    livingNodes.append(node)
                }
            } else if livingNeighborCount == 3 {
                var livingColor = sampleLivingNeighbor!.color
                if shiftingColors {
                    livingColor = livingColor.modified(withAdditionalHue: 0.005, additionalSaturation: 0, additionalBrightness: 0)
                }
                node.aliveColor = livingColor
                livingNodes.append(node)
                // Cell will change state - mark it and neighbors as active for next iteration
                nextActiveCells.insert(node)
                for neighbor in node.neighbors {
                    nextActiveCells.insert(neighbor)
                }
            } else {
                dyingNodes.append(node)
            }
        }

        // If entire tank is dead, generate a new tank!
        if CGFloat(livingNodes.count) == 0 {
            createRandomShapes(&dyingNodes, &livingNodes)
            // After regeneration, mark all new living nodes and their neighbors as active
            for node in livingNodes {
                nextActiveCells.insert(node)
                for neighbor in node.neighbors {
                    nextActiveCells.insert(neighbor)
                }
            }
        }

        // Static tank prevention using circular buffer
        historyBuffer[historyIndex] = livingNodes.count
        historyIndex = (historyIndex + 1) % 10
        if !historyFilled && historyIndex == 0 {
            historyFilled = true
        }

        if historyFilled {
            // Check for stasis: count unique values in history buffer
            var uniqueValues = Set<Int>()
            for value in historyBuffer {
                uniqueValues.insert(value)
            }
            if 1 ... 2 ~= uniqueValues.count {
                dyingNodes.append(contentsOf: livingNodes)
                livingNodes.removeAll()
                // After stasis reset, all cells become active for next generation
                nextActiveCells = Set(allNodes)
            }
        }

        // Update active cells for next iteration
        activeCells = nextActiveCells

        // Update nodes here
        dyingNodes.forEach {
            $0.die(duration: animationTime * 5, fade: deathFade)
        }

        livingNodes.forEach {
            $0.live(duration: animationTime)
        }

        aliveNodes = livingNodes
    }

    fileprivate func createRandomShapes(_: inout [LifeNode], _ livingNodes: inout [LifeNode]) {
        var totalShapes: Int = 0
        switch squareSize {
        case .ultraSmall:
            totalShapes = 2000
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

    // MARK: - Debug Input Handling

    #if os(macOS)
    override func keyDown(with event: NSEvent) {
        // Spacebar to toggle pause
        if event.keyCode == 49 {
            toggleLifePause()
        }
    }

    override func mouseDown(with event: NSEvent) {
        toggleLifePause()
    }
    #endif
}

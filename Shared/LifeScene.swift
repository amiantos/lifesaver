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

#if os(macOS)
import AppKit
#elseif os(tvOS) || os(iOS)
import UIKit
#endif

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
    private var fadeDelayTime: TimeInterval = 540
    var animationSpeed: AnimationSpeed = .normal {
        didSet {
            switch animationSpeed {
            case .fastest:
                animationTime = 0
                updateTime = 0.067
                fadeDelayTime = 90
            case .fast:
                animationTime = 0.6
                updateTime = 0.6
                fadeDelayTime = 180
            case .normal:
                animationTime = 2
                updateTime = 2
                fadeDelayTime = 540
            case .slow:
                animationTime = 5
                updateTime = 5
                fadeDelayTime = 900
            case .off:
                animationTime = 0
                updateTime = 0.1
                fadeDelayTime = 90
            }
        }
    }

    var squareSize: SquareSize = .medium
    var startingPattern: StartingPattern = .defaultRandom

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
        setupNotificationObservers()

        backgroundNode = SKSpriteNode(texture: squareTexture, color: appearanceColor, size: frame.size)
        backgroundNode.alpha = 0
        addChild(backgroundNode)
        backgroundNode.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        backgroundNode.zPosition = 0

        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        backgroundNode.run(fadeIn)

        createField()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - App Lifecycle Handling

    private func setupNotificationObservers() {
        #if os(macOS)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
        #elseif os(tvOS) || os(iOS)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        #endif
    }

    @objc private func handleDidBecomeActive() {
        resetTimingState()
        syncVisualState()
    }

    private func resetTimingState() {
        lastUpdate = 0
        stasisDetectedTime = nil
        activeCells.removeAll()  // Force full board check on next update
    }

    private func syncVisualState() {
        for node in allNodes {
            node.removeAllActions()
            if node.alive {
                node.alpha = 1.0
                node.color = node.aliveColor
            } else {
                node.alpha = deathFade ? 0.2 : 0
            }
        }
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
    private var boardSnapshots: [Set<CGPoint>] = [[], [], []]
    private var snapshotIndex: Int = 0
    private var snapshotsFilled: Bool = false
    private var stasisDetectedTime: TimeInterval?
    private var stasisResetDelay: TimeInterval { deathFade ? 30.0 : 5.0 }
    private var updatesSinceVisualSync: Int = 0
    private let visualSyncInterval: Int = 100  // Check all nodes every N updates
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
            startingPattern = manager.startingPattern
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
        boardSnapshots = [[], [], []]
        snapshotIndex = 0
        snapshotsFilled = false
        stasisDetectedTime = nil
        updatesSinceVisualSync = 0
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

        // Static tank prevention - compare board snapshots
        // Create snapshot of current living cell positions
        var currentSnapshot = Set<CGPoint>()
        for node in livingNodes {
            currentSnapshot.insert(node.relativePosition)
        }

        // Store in circular buffer of 3 boards
        boardSnapshots[snapshotIndex] = currentSnapshot
        snapshotIndex = (snapshotIndex + 1) % 3
        if !snapshotsFilled && snapshotIndex == 0 {
            snapshotsFilled = true
        }

        if snapshotsFilled {
            // Check if any 2 boards match (period-1 or period-2 oscillator)
            let match01 = boardSnapshots[0] == boardSnapshots[1]
            let match02 = boardSnapshots[0] == boardSnapshots[2]
            let match12 = boardSnapshots[1] == boardSnapshots[2]

            // Also check for very low population (e.g., single glider = 5 cells)
            let lowPopulation = livingNodes.count <= 5

            if match01 || match02 || match12 || lowPopulation {
                // Stasis detected - start timer if not already running
                if stasisDetectedTime == nil {
                    stasisDetectedTime = CACurrentMediaTime()
                }
            } else {
                // Not in stasis - reset timer
                stasisDetectedTime = nil
            }

            // Check if stasis timer has expired
            if let detectedTime = stasisDetectedTime,
               CACurrentMediaTime() - detectedTime >= stasisResetDelay {
                // For Gosper Gun, kill all existing cells before regenerating
                // so the gun can fire cleanly without interference
                if startingPattern == .gosperGun {
                    livingNodes.removeAll()
                    for node in allNodes where node.alive {
                        dyingNodes.append(node)
                    }
                }
                // Add new life (or replace for Gosper Gun)
                createRandomShapes(&dyingNodes, &livingNodes)
                // Mark new cells and their neighbors as active
                for node in livingNodes {
                    nextActiveCells.insert(node)
                    for neighbor in node.neighbors {
                        nextActiveCells.insert(neighbor)
                    }
                }
                // Reset snapshots and timer
                boardSnapshots = [[], [], []]
                snapshotIndex = 0
                snapshotsFilled = false
                stasisDetectedTime = nil
            }
        }

        // Update active cells for next iteration
        activeCells = nextActiveCells

        // Update nodes here
        dyingNodes.forEach {
            $0.die(duration: animationTime * 5, fadeDelay: fadeDelayTime, fade: deathFade)
        }

        livingNodes.forEach {
            $0.live(duration: animationTime)
        }

        aliveNodes = livingNodes

        // Periodic full-board visual consistency check
        // This catches any cells that got stuck with wrong alpha and aren't in activeCells
        updatesSinceVisualSync += 1
        if updatesSinceVisualSync >= visualSyncInterval {
            updatesSinceVisualSync = 0
            for node in allNodes where !node.hasActions() {
                if node.alive {
                    if node.alpha < 1 {
                        node.alpha = 1
                        node.color = node.aliveColor
                    }
                } else {
                    let expectedAlpha: CGFloat = deathFade ? 0.2 : 0
                    if node.alpha > expectedAlpha {
                        node.alpha = expectedAlpha
                    }
                }
            }
        }
    }

    fileprivate func createRandomShapes(_: inout [LifeNode], _ livingNodes: inout [LifeNode]) {
        switch startingPattern {
        case .defaultRandom:
            createDefaultRandomShapes(&livingNodes)
        case .sparse:
            createSparseShapes(&livingNodes)
        case .gliders:
            createGliderShapes(&livingNodes)
        case .sparseGliders:
            createSparseGliderShapes(&livingNodes)
        case .lonelyGliders:
            createLonelyGliderShapes(&livingNodes)
        case .gosperGun:
            createGosperGunShapes(&livingNodes)
        }
    }

    fileprivate func createDefaultRandomShapes(_ livingNodes: inout [LifeNode]) {
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

    fileprivate func createSparseShapes(_ livingNodes: inout [LifeNode]) {
        var totalShapes: Int = 0
        switch squareSize {
        case .ultraSmall:
            totalShapes = 1000
        case .superSmall:
            totalShapes = 250
        case .verySmall:
            totalShapes = 25
        case .small:
            totalShapes = 10
        case .medium:
            totalShapes = 5
        case .large:
            totalShapes = 2
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

    fileprivate func createGliderShapes(_ livingNodes: inout [LifeNode]) {
        var totalGliders: Int = 0
        switch squareSize {
        case .ultraSmall:
            totalGliders = 100
        case .superSmall:
            totalGliders = 50
        case .verySmall:
            totalGliders = 20
        case .small:
            totalGliders = 10
        case .medium:
            totalGliders = 4
        case .large:
            totalGliders = 2
        }

        // Four glider orientations for different diagonal directions
        let gliderOrientations = [
            // Down-right
            [(0, 1), (1, 0), (-1, -1), (0, -1), (1, -1)],
            // Down-left
            [(0, 1), (-1, 0), (1, -1), (0, -1), (-1, -1)],
            // Up-right
            [(0, -1), (1, 0), (-1, 1), (0, 1), (1, 1)],
            // Up-left
            [(0, -1), (-1, 0), (1, 1), (0, 1), (-1, 1)]
        ]

        for _ in 1 ... totalGliders {
            let centerX = Int.random(in: 2 ..< Int(lengthSquares) - 2)
            let centerY = Int.random(in: 2 ..< Int(heightSquares) - 2)
            let color = aliveColors.randomElement()!
            let gliderOffsets = gliderOrientations.randomElement()!

            for offset in gliderOffsets {
                let node = matrix[centerX + offset.0, centerY + offset.1]
                node.aliveColor = color
                livingNodes.append(node)
            }
        }
    }

    fileprivate func createSparseGliderShapes(_ livingNodes: inout [LifeNode]) {
        var totalGliders: Int = 0
        switch squareSize {
        case .ultraSmall:
            totalGliders = 50
        case .superSmall:
            totalGliders = 25
        case .verySmall:
            totalGliders = 10
        case .small:
            totalGliders = 5
        case .medium:
            totalGliders = 2
        case .large:
            totalGliders = 1
        }

        // Four glider orientations for different diagonal directions
        let gliderOrientations = [
            // Down-right
            [(0, 1), (1, 0), (-1, -1), (0, -1), (1, -1)],
            // Down-left
            [(0, 1), (-1, 0), (1, -1), (0, -1), (-1, -1)],
            // Up-right
            [(0, -1), (1, 0), (-1, 1), (0, 1), (1, 1)],
            // Up-left
            [(0, -1), (-1, 0), (1, 1), (0, 1), (-1, 1)]
        ]

        for _ in 1 ... totalGliders {
            let centerX = Int.random(in: 2 ..< Int(lengthSquares) - 2)
            let centerY = Int.random(in: 2 ..< Int(heightSquares) - 2)
            let color = aliveColors.randomElement()!
            let gliderOffsets = gliderOrientations.randomElement()!

            for offset in gliderOffsets {
                let node = matrix[centerX + offset.0, centerY + offset.1]
                node.aliveColor = color
                livingNodes.append(node)
            }
        }
    }

    fileprivate func createLonelyGliderShapes(_ livingNodes: inout [LifeNode]) {
        // Four glider orientations for different diagonal directions
        let gliderOrientations = [
            // Down-right
            [(0, 1), (1, 0), (-1, -1), (0, -1), (1, -1)],
            // Down-left
            [(0, 1), (-1, 0), (1, -1), (0, -1), (-1, -1)],
            // Up-right
            [(0, -1), (1, 0), (-1, 1), (0, 1), (1, 1)],
            // Up-left
            [(0, -1), (-1, 0), (1, 1), (0, 1), (-1, 1)]
        ]

        let width = Int(lengthSquares)
        let height = Int(heightSquares)

        // Place 3 gliders in different regions with different directions
        let placements: [(xRange: ClosedRange<Int>, yRange: ClosedRange<Int>, orientation: Int)] = [
            // Top-left region, going down-right
            (2...(width / 3), (height * 2 / 3)...(height - 3), 0),
            // Top-right region, going down-left
            ((width * 2 / 3)...(width - 3), (height * 2 / 3)...(height - 3), 1),
            // Bottom-center region, going up-right or up-left randomly
            ((width / 3)...(width * 2 / 3), 2...(height / 3), Int.random(in: 2...3))
        ]

        for (index, placement) in placements.enumerated() {
            let centerX = Int.random(in: placement.xRange)
            let centerY = Int.random(in: placement.yRange)
            let color = aliveColors[index % aliveColors.count]
            let gliderOffsets = gliderOrientations[placement.orientation]

            for offset in gliderOffsets {
                let node = matrix[centerX + offset.0, centerY + offset.1]
                node.aliveColor = color
                livingNodes.append(node)
            }
        }
    }

    fileprivate func createGosperGunShapes(_ livingNodes: inout [LifeNode]) {
        let width = Int(lengthSquares)
        let height = Int(heightSquares)

        // Gosper Glider Gun requires 36x9 minimum grid
        guard width >= 36 && height >= 9 else {
            // Fall back to default random if grid is too small
            createDefaultRandomShapes(&livingNodes)
            return
        }

        // Gosper Glider Gun pattern offsets (36 cells, 36x9 bounding box)
        // Pattern oriented with (0,0) at top-left of bounding box
        let gosperGunOffsets: [(Int, Int)] = [
            // Left square (block)
            (0, 4), (0, 5), (1, 4), (1, 5),
            // Left part of gun
            (10, 4), (10, 5), (10, 6),
            (11, 3), (11, 7),
            (12, 2), (12, 8),
            (13, 2), (13, 8),
            // Middle left
            (14, 5),
            (15, 3), (15, 7),
            (16, 4), (16, 5), (16, 6),
            (17, 5),
            // Middle right
            (20, 2), (20, 3), (20, 4),
            (21, 2), (21, 3), (21, 4),
            (22, 1), (22, 5),
            (24, 0), (24, 1), (24, 5), (24, 6),
            // Right square (block)
            (34, 2), (34, 3), (35, 2), (35, 3)
        ]

        // Pattern bounding box dimensions
        let patternWidth = 36
        let patternHeight = 9

        // Randomly flip horizontally and/or vertically for variety
        let flipHorizontal = Bool.random()
        let flipVertical = Bool.random()

        // Transform offsets based on flip settings
        let transformedOffsets = gosperGunOffsets.map { offset -> (Int, Int) in
            var x = offset.0
            var y = offset.1
            if flipHorizontal {
                x = (patternWidth - 1) - x
            }
            if flipVertical {
                y = (patternHeight - 1) - y
            }
            return (x, y)
        }

        // Center the pattern on the grid
        let startX = (width - patternWidth) / 2
        let startY = (height - patternHeight) / 2

        // Use a single color for all cells
        let color = aliveColors.randomElement()!

        for offset in transformedOffsets {
            let x = startX + offset.0
            let y = startY + offset.1
            let node = matrix[x, y]
            node.aliveColor = color
            livingNodes.append(node)
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

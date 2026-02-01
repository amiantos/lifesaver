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
            case .medium:
                animationTime = 0.3
                updateTime = 0.3
                fadeDelayTime = 135
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
    var gridMode: GridMode = .toroidal
    var respawnMode: RespawnMode = .freshStart
    private let bufferSize: Int = 20  // cells on each side for infinite mode
    private var visibleOriginX: Int = 0  // offset into matrix for visible area
    private var visibleOriginY: Int = 0

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
                node.alpha = deathFade ? 0.2 : 1.0  // Keep visible when fade is off
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
    private let stasisResetDelay: TimeInterval = 300.0  // 5 minutes
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
            gridMode = manager.gridMode
            respawnMode = manager.respawnMode
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
        // Calculate total grid dimensions based on grid mode
        let totalRows: Int
        let totalColumns: Int

        if gridMode == .infinite {
            totalRows = Int(lengthSquares) + (bufferSize * 2)
            totalColumns = Int(heightSquares) + (bufferSize * 2)
            visibleOriginX = bufferSize
            visibleOriginY = bufferSize
        } else {
            totalRows = Int(lengthSquares)
            totalColumns = Int(heightSquares)
            visibleOriginX = 0
            visibleOriginY = 0
        }

        matrix = ToroidalMatrix(
            rows: totalRows,
            columns: totalColumns,
            defaultValue: LifeNode(
                relativePosition: .zero,
                alive: false,
                color: .black,
                size: .zero
            )
        )

        let squareWidth: CGFloat = size.width / lengthSquares
        let squareHeight: CGFloat = size.height / heightSquares
        let squareSizeValue = CGSize(width: squareWidth, height: squareHeight)

        // Create all nodes (visible + buffer)
        for x in 0..<totalRows {
            for y in 0..<totalColumns {
                let relativePosition = CGPoint(x: x, y: y)

                // Calculate if this cell is in the visible area
                let isVisible = (x >= visibleOriginX && x < visibleOriginX + Int(lengthSquares) &&
                                y >= visibleOriginY && y < visibleOriginY + Int(heightSquares))

                // Only calculate screen position for visible cells
                let actualPosition: CGPoint
                if isVisible {
                    let screenX = CGFloat(x - visibleOriginX) * squareWidth
                    let screenY = CGFloat(y - visibleOriginY) * squareHeight
                    actualPosition = CGPoint(x: screenX, y: screenY)
                } else {
                    actualPosition = .zero  // Doesn't matter, won't be rendered
                }

                createLifeSquare(relativePosition, squareSizeValue, actualPosition, addToScene: isVisible)
            }
        }

        // Pre-fetch Neighbors
        for node in allNodes {
            createNeighbors(node)
        }
    }

    fileprivate func createLifeSquare(_ relativePosition: CGPoint, _ squareSize: CGSize, _ actualPosition: CGPoint, addToScene: Bool = true) {
        let newSquare = LifeNode(
            relativePosition: relativePosition,
            alive: false,
            color: appearanceColor,
            size: squareSize
        )

        if addToScene {
            addChild(newSquare)
            newSquare.position = actualPosition
            newSquare.alpha = 0
        }

        if newSquare.alive {
            aliveNodes.append(newSquare)
            newSquare.color = aliveColors.randomElement()!
        }
        allNodes.append(newSquare)
        matrix[Int(relativePosition.x), Int(relativePosition.y)] = newSquare
    }

    fileprivate func createNeighbors(_ node: LifeNode) {
        var neighbors: [LifeNode] = []
        let x = Int(node.relativePosition.x)
        let y = Int(node.relativePosition.y)

        let neighborOffsets = [
            (-1, 0), (1, 0), (0, 1), (0, -1),
            (1, 1), (-1, -1), (-1, 1), (1, -1)
        ]

        for (dx, dy) in neighborOffsets {
            let nx = x + dx
            let ny = y + dy

            if gridMode == .toroidal {
                // Current behavior - toroidal wrapping via subscript
                neighbors.append(matrix[nx, ny])
            } else {
                // Infinite mode - only add if within bounds (no wrapping)
                if matrix.indexIsValid(row: nx, column: ny) {
                    neighbors.append(matrix[nx, ny])
                }
                // Cells at absolute edge will have fewer neighbors and die naturally
            }
        }

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

        // If entire tank is dead (or nearly dead), generate a new tank immediately
        // to avoid making users wait staring at an empty or near-empty screen.
        let shouldRespawnImmediately = livingNodes.count <= 5

        if shouldRespawnImmediately {
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
        // Create snapshot of ALL living cell positions (not just the ones checked this iteration)
        var currentSnapshot = Set<CGPoint>()
        for node in allNodes where node.alive {
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

            // Note: Very low population (<=5 cells) now triggers immediate respawn above,
            // so we only need to detect oscillator stasis here
            if match01 || match02 || match12 {
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
                // In Fresh Start mode, kill all existing cells before regenerating
                // to prevent the board from becoming homogenous over time
                if respawnMode == .freshStart {
                    livingNodes.removeAll()
                    for node in allNodes where node.alive {
                        dyingNodes.append(node)
                    }
                }
                // Spawn new life
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
                } else if deathFade {
                    // Only enforce dimmed state when fade is enabled
                    if node.alpha > 0.2 {
                        node.alpha = 0.2
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
        case .rPentomino:
            createRPentominoShapes(&livingNodes)
        case .acorn:
            createAcornShapes(&livingNodes)
        case .pulsar:
            createPulsarShapes(&livingNodes)
        case .pufferTrain:
            createPufferTrainShapes(&livingNodes)
        case .piFusePuffer:
            createPiFusePufferShapes(&livingNodes)
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
            totalShapes = 500
        case .superSmall:
            totalShapes = 125
        case .verySmall:
            totalShapes = 12
        case .small:
            totalShapes = 5
        case .medium:
            totalShapes = 2
        case .large:
            totalShapes = 1
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
            let centerX = visibleOriginX + Int.random(in: 2 ..< Int(lengthSquares) - 2)
            let centerY = visibleOriginY + Int.random(in: 2 ..< Int(heightSquares) - 2)
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
            totalGliders = 25
        case .superSmall:
            totalGliders = 12
        case .verySmall:
            totalGliders = 5
        case .small:
            totalGliders = 2
        case .medium:
            totalGliders = 1
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
            let centerX = visibleOriginX + Int.random(in: 2 ..< Int(lengthSquares) - 2)
            let centerY = visibleOriginY + Int.random(in: 2 ..< Int(heightSquares) - 2)
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
            let centerX = visibleOriginX + Int.random(in: placement.xRange)
            let centerY = visibleOriginY + Int.random(in: placement.yRange)
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

        // Center the pattern on the visible grid with random offset for variety
        let maxOffsetX = min(2, (width - patternWidth) / 2)
        let maxOffsetY = min(2, (height - patternHeight) / 2)
        let randomOffsetX = Int.random(in: -maxOffsetX...maxOffsetX)
        let randomOffsetY = Int.random(in: -maxOffsetY...maxOffsetY)
        let startX = visibleOriginX + (width - patternWidth) / 2 + randomOffsetX
        let startY = visibleOriginY + (height - patternHeight) / 2 + randomOffsetY

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

    fileprivate func createRPentominoShapes(_ livingNodes: inout [LifeNode]) {
        let width = Int(lengthSquares)
        let height = Int(heightSquares)

        // R-pentomino requires 3x3 minimum grid
        guard width >= 3 && height >= 3 else {
            createDefaultRandomShapes(&livingNodes)
            return
        }

        // R-pentomino pattern offsets (5 cells, 3x3 bounding box)
        // Pattern:
        // .##
        // ##.
        // .#.
        let rPentominoOffsets: [(Int, Int)] = [
            (1, 0), (2, 0),
            (0, 1), (1, 1),
            (1, 2)
        ]

        let patternWidth = 3
        let patternHeight = 3

        // Randomly flip horizontally and/or vertically for variety
        let flipHorizontal = Bool.random()
        let flipVertical = Bool.random()

        let transformedOffsets = rPentominoOffsets.map { offset -> (Int, Int) in
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

        // Center the pattern on the visible grid
        let startX = visibleOriginX + (width - patternWidth) / 2
        let startY = visibleOriginY + (height - patternHeight) / 2

        let color = aliveColors.randomElement()!

        for offset in transformedOffsets {
            let x = startX + offset.0
            let y = startY + offset.1
            let node = matrix[x, y]
            node.aliveColor = color
            livingNodes.append(node)
        }
    }

    fileprivate func createAcornShapes(_ livingNodes: inout [LifeNode]) {
        let width = Int(lengthSquares)
        let height = Int(heightSquares)

        // Acorn requires 7x3 minimum grid
        guard width >= 7 && height >= 3 else {
            createDefaultRandomShapes(&livingNodes)
            return
        }

        // Acorn pattern offsets (7 cells, 7x3 bounding box)
        // Pattern:
        // .#.....
        // ...#...
        // ##..###
        let acornOffsets: [(Int, Int)] = [
            (1, 0),
            (3, 1),
            (0, 2), (1, 2), (4, 2), (5, 2), (6, 2)
        ]

        let patternWidth = 7
        let patternHeight = 3

        // Randomly flip horizontally and/or vertically for variety
        let flipHorizontal = Bool.random()
        let flipVertical = Bool.random()

        let transformedOffsets = acornOffsets.map { offset -> (Int, Int) in
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

        // Center the pattern on the visible grid
        let startX = visibleOriginX + (width - patternWidth) / 2
        let startY = visibleOriginY + (height - patternHeight) / 2

        let color = aliveColors.randomElement()!

        for offset in transformedOffsets {
            let x = startX + offset.0
            let y = startY + offset.1
            let node = matrix[x, y]
            node.aliveColor = color
            livingNodes.append(node)
        }
    }

    fileprivate func createPulsarShapes(_ livingNodes: inout [LifeNode]) {
        let width = Int(lengthSquares)
        let height = Int(heightSquares)

        // Pulsar requires 13x13 minimum grid
        guard width >= 13 && height >= 13 else {
            createDefaultRandomShapes(&livingNodes)
            return
        }

        // Pulsar pattern offsets (48 cells, 13x13 bounding box)
        // Symmetric period-3 oscillator
        // Pattern:
        // ..###...###..
        // .............
        // #....#.#....#
        // #....#.#....#
        // #....#.#....#
        // ..###...###..
        // .............
        // ..###...###..
        // #....#.#....#
        // #....#.#....#
        // #....#.#....#
        // .............
        // ..###...###..
        let pulsarOffsets: [(Int, Int)] = [
            // Top horizontal bars
            (2, 0), (3, 0), (4, 0), (8, 0), (9, 0), (10, 0),
            // Upper left vertical bar
            (0, 2), (0, 3), (0, 4),
            // Upper right vertical bar
            (12, 2), (12, 3), (12, 4),
            // Upper middle left vertical bar
            (5, 2), (5, 3), (5, 4),
            // Upper middle right vertical bar
            (7, 2), (7, 3), (7, 4),
            // Upper middle horizontal bars
            (2, 5), (3, 5), (4, 5), (8, 5), (9, 5), (10, 5),
            // Lower middle horizontal bars
            (2, 7), (3, 7), (4, 7), (8, 7), (9, 7), (10, 7),
            // Lower left vertical bar
            (0, 8), (0, 9), (0, 10),
            // Lower right vertical bar
            (12, 8), (12, 9), (12, 10),
            // Lower middle left vertical bar
            (5, 8), (5, 9), (5, 10),
            // Lower middle right vertical bar
            (7, 8), (7, 9), (7, 10),
            // Bottom horizontal bars
            (2, 12), (3, 12), (4, 12), (8, 12), (9, 12), (10, 12)
        ]

        let patternWidth = 13
        let patternHeight = 13

        // Randomly flip horizontally and/or vertically for variety
        // (Pulsar is symmetric, but this maintains consistency with other patterns)
        let flipHorizontal = Bool.random()
        let flipVertical = Bool.random()

        let transformedOffsets = pulsarOffsets.map { offset -> (Int, Int) in
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

        // Center the pattern on the visible grid
        let startX = visibleOriginX + (width - patternWidth) / 2
        let startY = visibleOriginY + (height - patternHeight) / 2

        let color = aliveColors.randomElement()!

        for offset in transformedOffsets {
            let x = startX + offset.0
            let y = startY + offset.1
            let node = matrix[x, y]
            node.aliveColor = color
            livingNodes.append(node)
        }
    }

    fileprivate func createPufferTrainShapes(_ livingNodes: inout [LifeNode]) {
        let width = Int(lengthSquares)
        let height = Int(heightSquares)

        // Puffer train requires 18x5 minimum grid (or 5x18 vertical)
        guard width >= 18 && height >= 5 else {
            createDefaultRandomShapes(&livingNodes)
            return
        }

        // Classic Puffer Train pattern (B-heptomino escorted by two LWSS)
        // From Golly patterns: x = 5, y = 18, rule = B3/S23
        // RLE: 3bo$4bo$o3bo$b4o4$o$boo$bbo$bbo$bo3$3bo$4bo$o3bo$b4o!
        // This pattern moves downward at c/2 speed, leaving debris behind
        //
        // Pattern (5 wide x 18 tall, vertical orientation):
        //    O      (0)
        //     O     (1)
        // O   O     (2)
        //  OOOO     (3)
        //           (4-6 empty)
        // O         (7)
        //  OO       (8)
        //   O       (9)
        //   O       (10)
        //  O        (11)
        //           (12-13 empty)
        //    O      (14)
        //     O     (15)
        // O   O     (16)
        //  OOOO     (17)
        let pufferTrainVertical: [(Int, Int)] = [
            // Top LWSS
            (3, 0),
            (4, 1),
            (0, 2), (4, 2),
            (1, 3), (2, 3), (3, 3), (4, 3),
            // B-heptomino
            (0, 7),
            (1, 8), (2, 8),
            (2, 9),
            (2, 10),
            (1, 11),
            // Bottom LWSS
            (3, 14),
            (4, 15),
            (0, 16), (4, 16),
            (1, 17), (2, 17), (3, 17), (4, 17)
        ]

        // Rotate 90° clockwise to make it horizontal (18 wide x 5 tall)
        // (x, y) -> (17 - y, x) for 90° clockwise rotation
        let pufferTrainHorizontal = pufferTrainVertical.map { (17 - $0.1, $0.0) }

        let patternWidth = 18
        let patternHeight = 5

        // Randomly flip for variety (changes movement direction)
        let flipHorizontal = Bool.random()
        let flipVertical = Bool.random()

        let transformedOffsets = pufferTrainHorizontal.map { offset -> (Int, Int) in
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

        // Center the pattern on the visible grid
        let startX = visibleOriginX + (width - patternWidth) / 2
        let startY = visibleOriginY + (height - patternHeight) / 2

        let color = aliveColors.randomElement()!

        for offset in transformedOffsets {
            let x = startX + offset.0
            let y = startY + offset.1
            let node = matrix[x, y]
            node.aliveColor = color
            livingNodes.append(node)
        }
    }

    fileprivate func createPiFusePufferShapes(_ livingNodes: inout [LifeNode]) {
        let width = Int(lengthSquares)
        let height = Int(heightSquares)

        // Pi fuse puffer requires 87x21 minimum grid (rotated to horizontal)
        guard width >= 87 && height >= 21 else {
            createDefaultRandomShapes(&livingNodes)
            return
        }

        // Pi Fuse Puffer pattern from Golly: x = 21, y = 87, rule = B3/S23
        // A space-filling puffer that grows while traveling
        // Original is vertical (21x87), we rotate to horizontal (87x21)
        let piFuseVertical: [(Int, Int)] = [
            // Row 0-9
            (4,0), (6,0),
            (4,1), (7,1), (13,1),
            (7,2), (8,2), (13,2), (14,2), (15,2), (16,2),
            (9,3), (15,3), (16,3),
            (7,4), (8,4), (9,4), (10,4), (18,4),
            (6,5), (11,5), (15,5), (16,5), (17,5), (18,5),
            (8,6), (11,6), (19,6),
            (8,7), (11,7), (15,7), (18,7), (19,7), (20,7),
            (10,8), (17,8), (18,8), (19,8),
            (4,9), (6,9), (7,9), (8,9), (9,9), (18,9),
            // Row 10-19
            (4,10), (8,10), (13,10), (15,10), (16,10), (17,10),
            (7,11), (13,11), (14,11), (17,11),
            (5,12), (7,12), (14,12), (15,12), (16,12),
            (14,13),
            (6,14), (7,14), (8,14), (16,14),
            (7,15), (8,15), (14,15), (16,15),
            (6,16), (7,16), (8,16), (17,16),
            (14,17), (16,17),
            (5,18), (7,18), (16,18),
            (5,19), (8,19), (14,19),
            // Row 20-29
            (8,20), (14,20), (15,20), (16,20),
            (6,21), (9,21), (15,21), (16,21), (17,21),
            (8,22), (9,22), (15,22), (16,22),
            (9,23), (11,23), (14,23), (15,23),
            (9,24), (11,24), (13,24), (14,24),
            (9,25),
            (6,26), (9,26), (11,26), (13,26), (14,26),
            (8,27), (9,27), (11,27), (14,27), (15,27),
            (6,28), (9,28), (15,28), (16,28),
            (9,29), (11,29), (14,29), (16,29), (17,29),
            // Row 30-39
            (6,30), (9,30), (11,30), (13,30), (14,30), (15,30), (18,30),
            (0,31), (1,31), (6,31), (9,31), (18,31),
            (0,32), (1,32), (6,32), (9,32), (11,32), (13,32), (14,32), (15,32), (18,32),
            (6,33), (9,33), (11,33), (14,33), (16,33), (17,33),
            (9,34), (15,34), (16,34),
            (6,35), (9,35), (11,35), (14,35), (15,35),
            (8,36), (9,36), (11,36), (13,36), (14,36),
            (6,37), (9,37),
            (9,38), (11,38), (13,38), (14,38),
            (6,39), (9,39), (11,39), (14,39), (15,39),
            // Row 40-49
            (6,40), (9,40), (15,40), (16,40),
            (9,41), (11,41), (14,41), (16,41), (17,41),
            (0,42), (1,42), (2,42), (6,42), (9,42), (11,42), (13,42), (14,42), (15,42), (18,42),
            (2,43), (8,43), (9,43), (18,43),
            (0,44), (1,44), (2,44), (6,44), (9,44), (11,44), (13,44), (14,44), (15,44), (18,44),
            (9,45), (11,45), (14,45), (16,45), (17,45),
            (6,46), (9,46), (15,46), (16,46),
            (6,47), (9,47), (11,47), (14,47), (15,47),
            (9,48), (11,48), (13,48), (14,48),
            (6,49), (9,49),
            // Row 50-59
            (8,50), (9,50), (11,50), (13,50), (14,50),
            (6,51), (9,51), (11,51), (14,51), (15,51),
            (9,52), (15,52), (16,52),
            (6,53), (9,53), (11,53), (14,53), (16,53), (17,53),
            (0,54), (1,54), (6,54), (9,54), (11,54), (13,54), (14,54), (15,54), (18,54),
            (0,55), (1,55), (6,55), (9,55), (18,55),
            (6,56), (9,56), (11,56), (13,56), (14,56), (15,56), (18,56),
            (9,57), (11,57), (14,57), (16,57), (17,57),
            (6,58), (9,58), (15,58), (16,58),
            (8,59), (9,59), (11,59), (14,59), (15,59),
            // Row 60-69
            (6,60), (9,60), (11,60), (13,60), (14,60),
            (9,61),
            (9,62), (11,62), (13,62), (14,62),
            (9,63), (11,63), (14,63), (15,63),
            (8,64), (9,64), (15,64), (16,64),
            (6,65), (9,65), (15,65), (16,65), (17,65),
            (8,66), (14,66), (15,66), (16,66),
            (5,67), (8,67), (14,67),
            (5,68), (7,68), (16,68),
            (14,69), (16,69),
            // Row 70-79
            (6,70), (7,70), (8,70), (17,70),
            (7,71), (8,71), (14,71), (16,71),
            (6,72), (7,72), (8,72), (16,72),
            (14,73),
            (5,74), (7,74), (14,74), (15,74), (16,74),
            (7,75), (13,75), (14,75), (17,75),
            (4,76), (8,76), (13,76), (15,76), (16,76), (17,76),
            (4,77), (6,77), (7,77), (8,77), (9,77), (18,77),
            (10,78), (17,78), (18,78), (19,78),
            (8,79), (11,79), (15,79), (18,79), (19,79), (20,79),
            // Row 80-86
            (8,80), (11,80), (19,80),
            (6,81), (11,81), (15,81), (16,81), (17,81), (18,81),
            (7,82), (8,82), (9,82), (10,82), (18,82),
            (9,83), (15,83), (16,83),
            (7,84), (8,84), (13,84), (14,84), (15,84), (16,84),
            (4,85), (7,85), (13,85),
            (4,86), (6,86)
        ]

        // Rotate 90° clockwise to make it horizontal (87 wide x 21 tall)
        // (x, y) -> (86 - y, x) for 90° clockwise rotation
        let piFuseHorizontal = piFuseVertical.map { (86 - $0.1, $0.0) }

        let patternWidth = 87
        let patternHeight = 21

        // Randomly flip for variety (changes movement direction)
        let flipHorizontal = Bool.random()
        let flipVertical = Bool.random()

        let transformedOffsets = piFuseHorizontal.map { offset -> (Int, Int) in
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

        // Center the pattern on the visible grid
        let startX = visibleOriginX + (width - patternWidth) / 2
        let startY = visibleOriginY + (height - patternHeight) / 2

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

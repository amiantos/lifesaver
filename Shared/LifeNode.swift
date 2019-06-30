//
//  LifeNode.swift
//  Life Saver
//
//  Created by Brad Root on 5/23/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SpriteKit

let squareTexture = FileGrabber.shared.getSKTexture(named: "square")

class LifeNode: SKSpriteNode {
    let relativePosition: CGPoint
    var alive: Bool
    var timeInState: Int = 0
    var aliveColor: SKColor
    var deadColor: SKColor
    var neighbors: [LifeNode] = []

    init(relativePosition: CGPoint, alive: Bool, color: SKColor, size: CGSize) {
        self.relativePosition = relativePosition
        self.alive = alive
        aliveColor = color
        deadColor = color
        super.init(texture: squareTexture, color: aliveColor, size: size)
        isUserInteractionEnabled = false
        anchorPoint = CGPoint(x: 0, y: 0)
        colorBlendFactor = 1
        zPosition = 0
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public func live(duration: TimeInterval) {
        if alive {
            timeInState += 1
            return
        }

        timeInState = 0
        alive = true

        if duration > 0 {
            removeAllActions()
            let fadeAction = SKAction.fadeAlpha(to: 1, duration: duration)
            let colorAction = SKAction.colorize(with: aliveColor, colorBlendFactor: 1, duration: duration)
            let actionGroup = SKAction.group([fadeAction, colorAction])
            actionGroup.timingMode = .easeInEaseOut
            run(actionGroup)
        } else {
            alpha = 1
            color = aliveColor
        }
    }

    public func die(duration: TimeInterval, fade: Bool) {
        if !alive {
            timeInState += 1

            // 30 for slow modes... 120 for fast?
            if timeInState == 120, duration > 0, fade {
                removeAllActions()
                let fadeAction = SKAction.fadeAlpha(to: 0, duration: duration)
                let colorAction = SKAction.colorize(with: deadColor, colorBlendFactor: 1, duration: duration)
                let actionGroup = SKAction.group([fadeAction, colorAction])
                actionGroup.timingMode = .easeIn
                run(actionGroup)
            }

            return
        }

        timeInState = 0
        alive = false

        if duration > 0, fade {
            removeAllActions()
            let fadeAction = SKAction.fadeAlpha(to: 0.2, duration: duration)
            fadeAction.timingMode = .easeInEaseOut
            run(fadeAction)
        } else if fade {
            alpha = 0.2
        }
    }

    public func remove(duration: TimeInterval) {
        removeAllActions()
        timeInState = 0
        alive = false

        let fadeAction = SKAction.fadeAlpha(to: 0, duration: duration)
        fadeAction.timingMode = .easeInEaseOut
        run(fadeAction) {
            self.removeFromParent()
        }
    }
}

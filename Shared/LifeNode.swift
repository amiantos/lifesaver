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

// MARK: - Cached SKActions for standard durations

private enum CachedActions {
    // Fade to full alpha (live action)
    static let fadeIn_0_1 = SKAction.fadeAlpha(to: 1, duration: 0.1)
    static let fadeIn_0_6 = SKAction.fadeAlpha(to: 1, duration: 0.6)
    static let fadeIn_2_0 = SKAction.fadeAlpha(to: 1, duration: 2.0)
    static let fadeIn_5_0 = SKAction.fadeAlpha(to: 1, duration: 5.0)

    // Fade to 0.2 alpha (initial death)
    static let fadeDim_0_1 = createFadeDimAction(duration: 0.1)
    static let fadeDim_0_6 = createFadeDimAction(duration: 0.6)
    static let fadeDim_2_0 = createFadeDimAction(duration: 2.0)
    static let fadeDim_5_0 = createFadeDimAction(duration: 5.0)

    // Fade to 0 alpha (full death after 120 cycles)
    static let fadeOut_0_5 = createFadeOutAction(duration: 0.5)
    static let fadeOut_3_0 = createFadeOutAction(duration: 3.0)
    static let fadeOut_10_0 = createFadeOutAction(duration: 10.0)
    static let fadeOut_25_0 = createFadeOutAction(duration: 25.0)

    private static func createFadeDimAction(duration: TimeInterval) -> SKAction {
        let action = SKAction.fadeAlpha(to: 0.2, duration: duration)
        action.timingMode = .easeInEaseOut
        return action
    }

    private static func createFadeOutAction(duration: TimeInterval) -> SKAction {
        let action = SKAction.fadeAlpha(to: 0, duration: duration)
        action.timingMode = .easeIn
        return action
    }

    static func fadeIn(duration: TimeInterval) -> SKAction? {
        switch duration {
        case 0.1: return fadeIn_0_1
        case 0.6: return fadeIn_0_6
        case 2.0: return fadeIn_2_0
        case 5.0: return fadeIn_5_0
        default: return nil
        }
    }

    static func fadeDim(duration: TimeInterval) -> SKAction? {
        switch duration {
        case 0.1: return fadeDim_0_1
        case 0.6: return fadeDim_0_6
        case 2.0: return fadeDim_2_0
        case 5.0: return fadeDim_5_0
        default: return nil
        }
    }

    static func fadeOut(duration: TimeInterval) -> SKAction? {
        switch duration {
        case 0.5: return fadeOut_0_5
        case 3.0: return fadeOut_3_0
        case 10.0: return fadeOut_10_0
        case 25.0: return fadeOut_25_0
        default: return nil
        }
    }
}

final class LifeNode: SKSpriteNode {
    let relativePosition: CGPoint
    var alive: Bool
    var timeInState: Int = 0
    var aliveColor: SKColor
    var deadColor: SKColor
    var neighbors: [LifeNode] = []

    // MARK: - Hashable (using object identity)

    override var hash: Int {
        return ObjectIdentifier(self).hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? LifeNode else { return false }
        return self === other
    }

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
            // Ensure visual state is correct - fix any desync
            if alpha < 1 && !hasActions() {
                alpha = 1
                color = aliveColor
            }
            return
        }

        timeInState = 0
        alive = true
        removeAllActions()  // Always cancel pending animations (especially stale death fades)

        if duration > 0 {
            // Use cached fade action if available, otherwise create new one
            let fadeAction = CachedActions.fadeIn(duration: duration)
                ?? SKAction.fadeAlpha(to: 1, duration: duration)
            let colorAction = SKAction.colorize(with: aliveColor, colorBlendFactor: 1, duration: duration)
            let actionGroup = SKAction.group([fadeAction, colorAction])
            actionGroup.timingMode = .easeInEaseOut
            run(actionGroup)
        } else {
            alpha = 1
            color = aliveColor
        }
    }

    public func die(duration: TimeInterval, fadeDelay: TimeInterval, fade: Bool) {
        if !alive {
            timeInState += 1
            // Ensure visual state is correct - fix any desync
            if !hasActions() {
                let expectedAlpha: CGFloat = fade ? 0.2 : 0
                if alpha > expectedAlpha {
                    alpha = expectedAlpha
                }
            }
            return
        }

        timeInState = 0
        alive = false

        removeAllActions()

        guard fade else {
            alpha = 0  // Immediately hide when no fade effect
            return
        }

        if duration > 0 {
            // Use cached fade action if available, otherwise create new one
            let fadeDimAction = CachedActions.fadeDim(duration: duration) ?? {
                let action = SKAction.fadeAlpha(to: 0.2, duration: duration)
                action.timingMode = .easeInEaseOut
                return action
            }()

            // Schedule the complete fade sequence: dim -> wait -> fade out
            let waitAction = SKAction.wait(forDuration: fadeDelay)
            let fadeOutAction = CachedActions.fadeOut(duration: duration) ?? {
                let action = SKAction.fadeAlpha(to: 0, duration: duration)
                action.timingMode = .easeIn
                return action
            }()
            let sequence = SKAction.sequence([fadeDimAction, waitAction, fadeOutAction])
            run(sequence)
        } else {
            // No animation for dim, but still schedule the delayed fade out
            alpha = 0.2
            let waitAction = SKAction.wait(forDuration: fadeDelay)
            let fadeOutAction = SKAction.fadeAlpha(to: 0, duration: 1.0)
            fadeOutAction.timingMode = .easeIn
            let sequence = SKAction.sequence([waitAction, fadeOutAction])
            run(sequence)
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

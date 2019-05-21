//
//  LifeSaverManager.swift
//  Life Saver
//
//  Created by Brad Root on 5/21/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation
import ScreenSaver
import SpriteKit

final class LifeSaverManager {
    private(set) var appearanceMode: Appearance
    private(set) var squareSize: SquareSize
    private(set) var animationSpeed: AnimationSpeed
    private(set) var blurAmount: BlurAmount
    private(set) var color1: SKColor
    private(set) var color2: SKColor
    private(set) var color3: SKColor

    // MARK: Init

    init() {
        appearanceMode = Database.standard.appearanceMode
        squareSize = Database.standard.squareSize
        animationSpeed = Database.standard.animationSpeed
        blurAmount = Database.standard.blurAmount
        color1 = Database.standard.getColor(.color1)
        color2 = Database.standard.getColor(.color2)
        color3 = Database.standard.getColor(.color3)
    }

    func setAppearanceMode(_ appearanceMode: Appearance) {
        self.appearanceMode = appearanceMode
        Database.standard.set(appearanceMode: appearanceMode)
    }

    func setSquareSize(_ squareSize: SquareSize) {
        self.squareSize = squareSize
        Database.standard.set(squareSize: squareSize)
    }

    func setAnimationSpeed(_ animationSpeed: AnimationSpeed) {
        self.animationSpeed = animationSpeed
        Database.standard.set(animationSpeed: animationSpeed)
    }

    func setBlurAmount(_ blurAmount: BlurAmount) {
        self.blurAmount = blurAmount
        Database.standard.set(blurAmount: blurAmount)
    }

    func setColor(_ color: SKColor, for colors: Colors) {
        switch colors {
        case .color1:
            color1 = color
        case .color2:
            color2 = color
        case .color3:
            color3 = color
        }
        Database.standard.set(color, for: colors)
    }
}

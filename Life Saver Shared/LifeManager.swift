//
//  LifeManager.swift
//  Life Saver
//
//  Created by Brad Root on 5/21/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import ScreenSaver
import SpriteKit

final class LifeManager {
    private(set) var appearanceMode: Appearance
    private(set) var squareSize: SquareSize
    private(set) var animationSpeed: AnimationSpeed
    private(set) var color1: SKColor
    private(set) var color2: SKColor
    private(set) var color3: SKColor
    private(set) var randomColorPreset: Bool

    init() {
        appearanceMode = LifeDatabase.standard.appearanceMode
        squareSize = LifeDatabase.standard.squareSize
        animationSpeed = LifeDatabase.standard.animationSpeed
        color1 = LifeDatabase.standard.getColor(.color1)
        color2 = LifeDatabase.standard.getColor(.color2)
        color3 = LifeDatabase.standard.getColor(.color3)
        randomColorPreset = LifeDatabase.standard.randomColorPreset
    }

    func configure(with preset: LifePreset) {
        if let appearanceMode = preset.appearanceMode {
            self.setAppearanceMode(appearanceMode)
        }

        if let squareSize = preset.squareSize {
            self.setSquareSize(squareSize)
        }

        if let animationSpeed = preset.animationSpeed {
            self.setAnimationSpeed(animationSpeed)
        }

        if let color1 = preset.color1 {
            self.setColor(color1, for: .color1)
        }

        if let color2 = preset.color2 {
            self.setColor(color2, for: .color2)
        }

        if let color3 = preset.color3 {
            self.setColor(color3, for: .color3)
        }
    }

    func setRandomColorPreset(_ randomColorPreset: Bool) {
        self.randomColorPreset = randomColorPreset
        LifeDatabase.standard.set(randomColorPreset: randomColorPreset)
    }

    func setAppearanceMode(_ appearanceMode: Appearance) {
        self.appearanceMode = appearanceMode
        LifeDatabase.standard.set(appearanceMode: appearanceMode)
    }

    func setSquareSize(_ squareSize: SquareSize) {
        self.squareSize = squareSize
        LifeDatabase.standard.set(squareSize: squareSize)
    }

    func setAnimationSpeed(_ animationSpeed: AnimationSpeed) {
        self.animationSpeed = animationSpeed
        LifeDatabase.standard.set(animationSpeed: animationSpeed)
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
        LifeDatabase.standard.set(color, for: colors)
    }
}

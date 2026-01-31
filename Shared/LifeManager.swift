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
import SpriteKit

protocol LifeManagerDelegate: AnyObject {
    func updatedSettings()
}

final class LifeManager {
    private(set) var appearanceMode: Appearance
    private(set) var squareSize: SquareSize
    private(set) var animationSpeed: AnimationSpeed
    private(set) var color1: SKColor
    private(set) var color2: SKColor
    private(set) var color3: SKColor
    private(set) var randomColorPreset: Bool
    private(set) var shiftingColors: Bool
    private(set) var deathFade: Bool
    private(set) var selectedPresetTitle: String
    private(set) var hasPressedMenuButton: Bool
    private(set) var startingPattern: StartingPattern
    private(set) var isCustomizeMode: Bool
    private(set) var gridMode: GridMode

    private var usingPreset: Bool = false

    weak var delegate: LifeManagerDelegate?
    weak var settingsDelegate: LifeManagerDelegate?

    init() {
        appearanceMode = LifeDatabase.standard.appearanceMode
        squareSize = LifeDatabase.standard.squareSize
        animationSpeed = LifeDatabase.standard.animationSpeed
        color1 = LifeDatabase.standard.getColor(.color1)
        color2 = LifeDatabase.standard.getColor(.color2)
        color3 = LifeDatabase.standard.getColor(.color3)
        randomColorPreset = LifeDatabase.standard.randomColorPreset
        deathFade = LifeDatabase.standard.deathFade
        shiftingColors = LifeDatabase.standard.shiftingColors
        selectedPresetTitle = LifeDatabase.standard.selectedPresetTitle
        hasPressedMenuButton = LifeDatabase.standard.hasPressedMenuButton
        startingPattern = LifeDatabase.standard.startingPattern
        isCustomizeMode = LifeDatabase.standard.isCustomizeMode
        gridMode = LifeDatabase.standard.gridMode
    }

    func configure(with preset: LifePreset) {
        usingPreset = true

        if let appearanceMode = preset.appearanceMode {
            setAppearanceMode(appearanceMode)
        }

        if let squareSize = preset.squareSize {
            setSquareSize(squareSize)
        }

        if let animationSpeed = preset.animationSpeed {
            setAnimationSpeed(animationSpeed)
        }

        if let deathFade = preset.deathFade {
            setDeathFade(deathFade)
        }

        if let shiftingColors = preset.shiftingColors {
            setShiftingColors(shiftingColors)
        }

        if let startingPattern = preset.startingPattern {
            setStartingPattern(startingPattern)
        }

        if let color1 = preset.color1 {
            setColor(color1, for: .color1)
        }

        if let color2 = preset.color2 {
            setColor(color2, for: .color2)
        }

        if let color3 = preset.color3 {
            setColor(color3, for: .color3)
        }

        selectedPresetTitle = preset.title
        LifeDatabase.standard.set(selectedPresetTitle: selectedPresetTitle)

        usingPreset = false
        sendUpdateMessage()
    }

    func setRandomColorPreset(_ randomColorPreset: Bool) {
        self.randomColorPreset = randomColorPreset
        LifeDatabase.standard.set(randomColorPreset: randomColorPreset)
        sendUpdateMessage()
    }

    func setShiftingColors(_ shiftingColors: Bool) {
        self.shiftingColors = shiftingColors
        LifeDatabase.standard.set(shiftingColors: shiftingColors)
        sendUpdateMessage()
    }

    func setDeathFade(_ deathFade: Bool) {
        self.deathFade = deathFade
        LifeDatabase.standard.set(deathFade: deathFade)
        sendUpdateMessage()
    }

    func setHasPressedMenuButton(_ hasPressedMenuButton: Bool) {
        self.hasPressedMenuButton = hasPressedMenuButton
        LifeDatabase.standard.set(hasPressedMenuButton: hasPressedMenuButton)
    }

    func setIsCustomizeMode(_ isCustomizeMode: Bool) {
        self.isCustomizeMode = isCustomizeMode
        LifeDatabase.standard.set(isCustomizeMode: isCustomizeMode)
    }

    func setGridMode(_ gridMode: GridMode) {
        self.gridMode = gridMode
        LifeDatabase.standard.set(gridMode: gridMode)
        sendUpdateMessage()
    }

    func setStartingPattern(_ startingPattern: StartingPattern) {
        self.startingPattern = startingPattern
        LifeDatabase.standard.set(startingPattern: startingPattern)
        sendUpdateMessage()
    }

    func setAppearanceMode(_ appearanceMode: Appearance) {
        self.appearanceMode = appearanceMode
        LifeDatabase.standard.set(appearanceMode: appearanceMode)
        sendUpdateMessage()
    }

    func setSquareSize(_ squareSize: SquareSize) {
        self.squareSize = squareSize
        LifeDatabase.standard.set(squareSize: squareSize)
        sendUpdateMessage()
    }

    func setAnimationSpeed(_ animationSpeed: AnimationSpeed) {
        self.animationSpeed = animationSpeed
        LifeDatabase.standard.set(animationSpeed: animationSpeed)
        sendUpdateMessage()
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

        if !usingPreset {
            selectedPresetTitle = ""
            LifeDatabase.standard.set(selectedPresetTitle: selectedPresetTitle)
        }

        sendUpdateMessage()
    }

    func sendUpdateMessage() {
        if !usingPreset {
            delegate?.updatedSettings()
            settingsDelegate?.updatedSettings()
        }
    }
}

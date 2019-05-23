//
//  LifeSettings.swift
//  Life Saver Screensaver
//
//  Created by Brad Root on 5/23/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import SpriteKit

struct LifeSettings {
    let title: String
    let appearanceMode: Appearance?
    let squareSize: SquareSize?
    let animationSpeed: AnimationSpeed?
    let color1: SKColor?
    let color2: SKColor?
    let color3: SKColor?
}

enum Appearance: Int {
    case light = 0
    case dark = 1
}

enum SquareSize: Int {
    case small = 0
    case medium = 1
    case large = 2
}

enum AnimationSpeed: Int {
    case fast = 0
    case normal = 1
    case slow = 2
}

enum Colors: Int {
    case color1 = 0
    case color2 = 1
    case color3 = 2
}

extension SKColor {
    static let defaultColor1 = SKColor(red: 172 / 255.0, green: 48 / 255.0, blue: 17 / 255.0, alpha: 1.00)
    static let defaultColor2 = SKColor(red: 6 / 255.0, green: 66 / 255.0, blue: 110 / 255.0, alpha: 1.00)
    static let defaultColor3 = SKColor(red: 174 / 255.0, green: 129 / 255.0, blue: 0 / 255.0, alpha: 1.00)
}

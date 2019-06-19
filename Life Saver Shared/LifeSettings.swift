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
    case superSmall = -2
    case verySmall = -1
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

let lifePresets = [
    LifeSettings(
        title: "Santa Fe",
        appearanceMode: .dark,
        squareSize: nil,
        animationSpeed: nil,
        color1: SKColor.defaultColor1,
        color2: SKColor.defaultColor2,
        color3: SKColor.defaultColor3
    ),
    LifeSettings(
        title: "Braineater",
        appearanceMode: .dark,
        squareSize: nil,
        animationSpeed: nil,
        color1: SKColor(red: 103 / 255.0, green: 22 / 255.0, blue: 169 / 255.0, alpha: 1.00),
        color2: SKColor(red: 13 / 255.0, green: 17 / 255.0, blue: 108 / 255.0, alpha: 1.00),
        color3: SKColor(red: 12 / 255.0, green: 67 / 255.0, blue: 108 / 255.0, alpha: 1.00)
    ),
    LifeSettings(
        title: "Reign In Blood",
        appearanceMode: .dark,
        squareSize: nil,
        animationSpeed: nil,
        color1: SKColor(red: 113 / 255.0, green: 17 / 255.0, blue: 8 / 255.0, alpha: 1.00),
        color2: SKColor(red: 95 / 255.0, green: 7 / 255.0, blue: 0 / 255.0, alpha: 1.00),
        color3: SKColor(red: 55 / 255.0, green: 55 / 255.0, blue: 55 / 255.0, alpha: 1.00)
    ),
    LifeSettings(
        title: "Swamp Girl",
        appearanceMode: .dark,
        squareSize: nil,
        animationSpeed: nil,
        color1: SKColor(red: 173 / 255.0, green: 255 / 255.0, blue: 14 / 255.0, alpha: 1.00),
        color2: SKColor(red: 174 / 255.0, green: 129 / 255.0, blue: 255 / 255.0, alpha: 1.00),
        color3: SKColor(red: 6 / 255.0, green: 66 / 255.0, blue: 110 / 255.0, alpha: 1.00)
    ),
    LifeSettings(
        title: "This Is America",
        appearanceMode: .dark,
        squareSize: nil,
        animationSpeed: nil,
        color1: SKColor(red: 190 / 255.0, green: 14 / 255.0, blue: 19 / 255.0, alpha: 1.00),
        color2: SKColor(red: 39 / 255.0, green: 65 / 255.0, blue: 110 / 255.0, alpha: 1.00),
        color3: SKColor(red: 212 / 255.0, green: 205 / 255.0, blue: 196 / 255.0, alpha: 1.00)
    ),
    LifeSettings(
        title: "The Noun Project",
        appearanceMode: .dark,
        squareSize: nil,
        animationSpeed: nil,
        color1: SKColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0, alpha: 1.00),
        color2: SKColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0, alpha: 1.00),
        color3: SKColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0, alpha: 1.00)
    ),
    LifeSettings(
        title: "Lingo",
        appearanceMode: .light,
        squareSize: nil,
        animationSpeed: nil,
        color1: SKColor(red: 252 / 255.0, green: 98 / 255.0, blue: 101 / 255.0, alpha: 1.00),
        color2: SKColor(red: 88 / 255.0, green: 137 / 255.0, blue: 251 / 255.0, alpha: 1.00),
        color3: SKColor(red: 38 / 255.0, green: 205 / 255.0, blue: 105 / 255.0, alpha: 1.00)
    ),
    LifeSettings(
        title: "Deuteranopia",
        appearanceMode: .dark,
        squareSize: nil,
        animationSpeed: nil,
        color1: SKColor(red: 211 / 255.0, green: 208 / 255.0, blue: 203 / 255.0, alpha: 1.00),
        color2: SKColor(red: 88 / 255.0, green: 123 / 255.0, blue: 127 / 255.0, alpha: 1.00),
        color3: SKColor(red: 255 / 255.0, green: 173 / 255.0, blue: 105 / 255.0, alpha: 1.00)
    ),
    LifeSettings(
        title: "Retro Pastel",
        appearanceMode: .light,
        squareSize: nil,
        animationSpeed: nil,
        color1: SKColor(red: 229 / 255.0, green: 167 / 255.0, blue: 177 / 255.0, alpha: 1.00),
        color2: SKColor(red: 244 / 255.0, green: 243 / 255.0, blue: 216 / 255.0, alpha: 1.00),
        color3: SKColor(red: 175 / 255.0, green: 211 / 255.0, blue: 213 / 255.0, alpha: 1.00)
    ),
    LifeSettings(
        title: "Better Days",
        appearanceMode: .dark,
        squareSize: nil,
        animationSpeed: nil,
        color1: SKColor(red: 95 / 255.0, green: 67 / 255.0, blue: 107 / 255.0, alpha: 1.00),
        color2: SKColor(red: 205 / 255.0, green: 170 / 255.0, blue: 37 / 255.0, alpha: 1.00),
        color3: SKColor(red: 114 / 255.0, green: 100 / 255.0, blue: 87 / 255.0, alpha: 1.00)
    ),
    LifeSettings(
        title: "Bubblegum",
        appearanceMode: .light,
        squareSize: nil,
        animationSpeed: nil,
        color1: SKColor(red: 1 / 255.0, green: 153 / 255.0, blue: 138 / 255.0, alpha: 1.00),
        color2: SKColor(red: 255 / 255.0, green: 203 / 255.0, blue: 213 / 255.0, alpha: 1.00),
        color3: SKColor(red: 191 / 255.0, green: 178 / 255.0, blue: 95 / 255.0, alpha: 1.00)
    ),
    LifeSettings(
        title: "Teenage Chapstick",
        appearanceMode: .dark,
        squareSize: nil,
        animationSpeed: nil,
        color1: SKColor(red: 208 / 255.0, green: 117 / 255.0, blue: 126 / 255.0, alpha: 1.00),
        color2: SKColor(red: 44 / 255.0, green: 80 / 255.0, blue: 80 / 255.0, alpha: 1.00),
        color3: SKColor(red: 156 / 255.0, green: 154 / 255.0, blue: 23 / 255.0, alpha: 1.00)
    ),
    LifeSettings(
        title: "Georgia",
        appearanceMode: .light,
        squareSize: nil,
        animationSpeed: nil,
        color1: SKColor(red: 237 / 255.0, green: 200 / 255.0, blue: 195 / 255.0, alpha: 1.00),
        color2: SKColor(red: 16 / 255.0, green: 103 / 255.0, blue: 110 / 255.0, alpha: 1.00),
        color3: SKColor(red: 247 / 255.0, green: 172 / 255.0, blue: 153 / 255.0, alpha: 1.00)
    ),
    LifeSettings(
        title: "Boysenberry",
        appearanceMode: .dark,
        squareSize: nil,
        animationSpeed: nil,
        color1: SKColor(red: 122 / 255.0, green: 55 / 255.0, blue: 100 / 255.0, alpha: 1.00),
        color2: SKColor(red: 56 / 255.0, green: 66 / 255.0, blue: 109 / 255.0, alpha: 1.00),
        color3: SKColor(red: 160 / 255.0, green: 121 / 255.0, blue: 72 / 255.0, alpha: 1.00)
    ),
    LifeSettings(
        title: "Tal Véz",
        appearanceMode: .dark,
        squareSize: nil,
        animationSpeed: nil,
        color1: SKColor(red: 59 / 255.0, green: 67 / 255.0, blue: 72 / 255.0, alpha: 1.00),
        color2: SKColor(red: 247 / 255.0, green: 201 / 255.0, blue: 177 / 255.0, alpha: 1.00),
        color3: SKColor(red: 176 / 255.0, green: 197 / 255.0, blue: 223 / 255.0, alpha: 1.00)
    ),
    LifeSettings(
        title: "Deep Forest",
        appearanceMode: .dark,
        squareSize: nil,
        animationSpeed: nil,
        color1: SKColor(red: 36 / 255.0, green: 55 / 255.0, blue: 13 / 255.0, alpha: 1.00),
        color2: SKColor(red: 55 / 255.0, green: 60 / 255.0, blue: 13 / 255.0, alpha: 1.00),
        color3: SKColor(red: 10 / 255.0, green: 44 / 255.0, blue: 24 / 255.0, alpha: 1.00)
    ),
    LifeSettings(
        title: "Bite Me",
        appearanceMode: .dark,
        squareSize: nil,
        animationSpeed: nil,
        color1: SKColor(red: 243 / 255.0, green: 136 / 255.0, blue: 103 / 255.0, alpha: 1.00),
        color2: SKColor(red: 241 / 255.0, green: 188 / 255.0, blue: 151 / 255.0, alpha: 1.00),
        color3: SKColor(red: 252 / 255.0, green: 53 / 255.0, blue: 113 / 255.0, alpha: 1.00)
    ),
    LifeSettings(
        title: "Custom",
        appearanceMode: nil,
        squareSize: nil,
        animationSpeed: nil,
        color1: nil,
        color2: nil,
        color3: nil
    )
]

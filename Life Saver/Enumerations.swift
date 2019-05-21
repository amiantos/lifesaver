//
//  Enumerations.swift
//  Life Saver
//
//  Created by Brad Root on 5/21/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation
import SpriteKit

enum Appearance: Int {
    case light = 0
    case dark = 1
}

enum SquareSize: Int {
    case small = 0
    case medium = 1
    case large = 2
}

enum BlurAmount: Int {
    case none = 0
    case some = 1
    case heavy = 2
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

//
//  Extensions.swift
//  Life Saver
//
//  Created by Brad Root on 5/21/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation
import SpriteKit

extension NSObject {
    static var identifier: String { return String(describing: self) }
}

extension SKColor {
    static let defaultColor1 = SKColor(red: 172 / 255.0, green: 48 / 255.0, blue: 17 / 255.0, alpha: 1.00)
    static let defaultColor2 = SKColor(red: 6 / 255.0, green: 66 / 255.0, blue: 110 / 255.0, alpha: 1.00)
    static let defaultColor3 = SKColor(red: 174 / 255.0, green: 129 / 255.0, blue: 0 / 255.0, alpha: 1.00)
}

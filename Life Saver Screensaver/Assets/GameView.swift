//
//  GameView.swift
//  SwiftScreenSaver
//
//  Created by Patrick Winchell on 1/22/16.
//  Copyright © 2016 Patrick Winchell. All rights reserved.
//

import Cocoa
import SpriteKit

class GameView: SKView {
    override var acceptsFirstResponder: Bool { return false }

    override var frame: NSRect {
        didSet {
            scene?.size = frame.size
        }
    }
}

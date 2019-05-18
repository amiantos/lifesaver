//
//  ScreenSaverView.swift
//  Life Saver Screensaver
//
//  Created by Bradley Root on 5/18/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Cocoa
import ScreenSaver
import SpriteKit

class LifeScreenSaverView: ScreenSaverView {
    var spriteView: GameView?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = 1.0
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        animationTimeInterval = 1.0
    }

    override var frame: NSRect {
        didSet {
            self.spriteView?.frame = frame
        }
    }

    override func startAnimation() {
        if spriteView == nil {
            let spriteView = GameView(frame: frame)
            spriteView.ignoresSiblingOrder = true
            spriteView.showsFPS = false
            spriteView.showsNodeCount = false
            let scene = LifeScene(size: frame.size)
            self.spriteView = spriteView
            addSubview(spriteView)
            spriteView.presentScene(scene)
        }
        super.startAnimation()
    }
}

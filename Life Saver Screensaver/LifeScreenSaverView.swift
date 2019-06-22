//
//  ScreenSaverView.swift
//  Life Saver Screensaver
//
//  Created by Bradley Root on 5/18/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation
import ScreenSaver
import SpriteKit

final class LifeScreenSaverView: ScreenSaverView {
    var spriteView: SKView?

    lazy var sheetController: ConfigureSheetController = ConfigureSheetController()

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

    override var hasConfigureSheet: Bool {
        return true
    }

    override var configureSheet: NSWindow? {
        return sheetController.window
    }

    override func startAnimation() {
        if spriteView == nil {
            let manager = LifeManager()
            let spriteView = SKView(frame: frame)
            spriteView.ignoresSiblingOrder = true
            spriteView.showsFPS = false
            spriteView.showsNodeCount = false
            let scene = LifeScene(size: frame.size)
            self.spriteView = spriteView
            addSubview(spriteView)

            if manager.randomColorPreset, let preset = lifePresets.randomElement() {
                manager.configure(with: preset)
            }

            scene.appearanceMode = manager.appearanceMode
            scene.squareSize = manager.squareSize
            scene.animationSpeed = manager.animationSpeed
            scene.aliveColors = [manager.color1, manager.color2, manager.color3]
            scene.isUserInteractionEnabled = false

            spriteView.presentScene(scene)
        }
        super.startAnimation()
    }

    override func stopAnimation() {
        super.stopAnimation()
        spriteView = nil
    }
}

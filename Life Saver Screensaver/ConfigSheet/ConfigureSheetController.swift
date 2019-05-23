//
//  ConfigureSheetController.swift
//  Life Saver Screensaver
//
//  Created by Brad Root on 5/21/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Cocoa
import SpriteKit

struct LifeSettings {
    let appearanceMode: Appearance?
    let squareSize: SquareSize?
    let animationSpeed: AnimationSpeed?
    let color1: SKColor?
    let color2: SKColor?
    let color3: SKColor?
}

enum LifePresets: String, CaseIterable {
    case defaults = "Settings: Default"
    case defaultsAbstract = "Settings: Abstract"
    case defaultsSimulation = "Settings: Simulation"
    case colorsDefaults = "Colors: Santa Fe"
    case colorsDusk = "Colors: Dusk"
    case colorsSwampGirl = "Colors: Swamp Girl"
}

extension LifeSettings {
    static let defaults = LifeSettings(appearanceMode: .dark, squareSize: .medium, animationSpeed: .normal, color1: nil, color2: nil, color3: nil)
    static let defaultsAbstract = LifeSettings(appearanceMode: .dark, squareSize: .large, animationSpeed: .slow, color1: nil, color2: nil, color3: nil)
    static let defaultsSimulation = LifeSettings(appearanceMode: .dark, squareSize: .small, animationSpeed: .fast, color1: nil, color2: nil, color3: nil)
    static let colorsDefaults = LifeSettings(appearanceMode: nil, squareSize: nil, animationSpeed: nil, color1: SKColor.defaultColor1, color2: SKColor.defaultColor2, color3: SKColor.defaultColor3)
    static let colorsDusk = LifeSettings(appearanceMode: nil, squareSize: nil, animationSpeed: nil, color1: SKColor(red: 103/255.0, green: 22/255.0, blue: 169/255.0, alpha: 1.00), color2: SKColor(red: 13/255.0, green: 17/255.0, blue: 108/255.0, alpha: 1.00), color3: SKColor(red: 12/255.0, green: 67/255.0, blue: 108/255.0, alpha: 1.00))
    static let colorsSwampGirl = LifeSettings(appearanceMode: nil, squareSize: nil, animationSpeed: nil, color1: SKColor(red: 173/255.0, green: 255/255.0, blue: 14/255.0, alpha: 1.00), color2: SKColor(red: 174/255.0, green: 129/255.0, blue: 255/255.0, alpha: 1.00), color3: SKColor(red: 6/255.0, green: 66/255.0, blue: 110/255.0, alpha: 1.00))
}

class ConfigureSheetController: NSObject {
    @IBOutlet var window: NSWindow?

    private let manager = LifeSaverManager()

    @IBOutlet var presetsButton: NSPopUpButton!
    @IBAction func presetsAction(_ sender: NSPopUpButton) {
        guard let title = sender.titleOfSelectedItem else { return }
        guard let preset = LifePresets(rawValue: title) else { return }
        switch preset {
        case .defaults:
            setupFields(with: LifeSettings.defaults)
        case .defaultsAbstract:
            setupFields(with: LifeSettings.defaultsAbstract)
        case .defaultsSimulation:
            setupFields(with: LifeSettings.defaultsSimulation)
        case .colorsDefaults:
            setupFields(with: LifeSettings.colorsDefaults)
        case .colorsDusk:
            setupFields(with: LifeSettings.colorsDusk)
        case .colorsSwampGirl:
            setupFields(with: LifeSettings.colorsSwampGirl)
        }
    }

    @IBAction func appearanceAction(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 1:
            manager.setAppearanceMode(Appearance.light)
        default:
            manager.setAppearanceMode(Appearance.dark)
        }
    }

    @IBOutlet var appearanceControl: NSSegmentedControl!

    @IBAction func squareSizeAction(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            manager.setSquareSize(.small)
        case 2:
            manager.setSquareSize(.large)
        default:
            manager.setSquareSize(.medium)
        }
    }

    @IBOutlet var squareSizeControl: NSSegmentedControl!

    @IBAction func animationSpeedAction(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            manager.setAnimationSpeed(.fast)
        case 2:
            manager.setAnimationSpeed(.slow)
        default:
            manager.setAnimationSpeed(.normal)
        }
    }

    @IBOutlet var animationSpeedControl: NSSegmentedControl!

    @IBOutlet var blurAmountControl: NSSegmentedControl!

    @IBOutlet var color1Well: NSColorWell!
    @IBAction func color1Action(_ sender: NSColorWell) {
        manager.setColor(sender.color as SKColor, for: .color1)
    }

    @IBOutlet var color2Well: NSColorWell!
    @IBAction func color2Action(_ sender: NSColorWell) {
        manager.setColor(sender.color as SKColor, for: .color2)
    }

    @IBOutlet var color3Well: NSColorWell!
    @IBAction func color3Action(_ sender: NSColorWell) {
        manager.setColor(sender.color as SKColor, for: .color3)
    }

    @IBOutlet var twitterButton: NSButton!
    @IBAction func twitterAction(_: NSButton) {
        URLType.twitter.open()
    }

    @IBOutlet var gitHubButton: NSButton!
    @IBAction func gitHubAction(_: NSButton) {
        URLType.github.open()
    }

    @IBAction func bradAction(_: NSButton) {
        URLType.brad.open()
    }

    @IBAction func closeConfigureSheet(sender _: AnyObject) {
        guard let window = window else { return }
        window.sheetParent?.endSheet(window)
    }

    override init() {
        super.init()
        let myBundle = Bundle(for: ConfigureSheetController.self)
        myBundle.loadNibNamed("ConfigureSheet", owner: self, topLevelObjects: nil)

        setupFields()
        setupPresets()
    }

    fileprivate func setupFields() {
        switch manager.appearanceMode {
        case .dark:
            appearanceControl.selectedSegment = 0
        case .light:
            appearanceControl.selectedSegment = 1
        }

        switch manager.squareSize {
        case .small:
            squareSizeControl.selectedSegment = 0
        case .medium:
            squareSizeControl.selectedSegment = 1
        case .large:
            squareSizeControl.selectedSegment = 2
        }

        switch manager.animationSpeed {
        case .normal:
            animationSpeedControl.selectedSegment = 1
        case .fast:
            animationSpeedControl.selectedSegment = 0
        case .slow:
            animationSpeedControl.selectedSegment = 2
        }

        color1Well.color = manager.color1
        color2Well.color = manager.color2
        color3Well.color = manager.color3
    }

    fileprivate func setupPresets() {
        presetsButton.removeAllItems()
        var presetTitles: [String] = []
        for preset in LifePresets.allCases {
            presetTitles.append(preset.rawValue)
        }
        presetsButton.addItems(withTitles: presetTitles)
    }

    fileprivate func setupFields(with preset: LifeSettings) {
        if let appearanceMode = preset.appearanceMode {
            switch appearanceMode {
            case .dark:
                appearanceControl.selectedSegment = 0
            case .light:
                appearanceControl.selectedSegment = 1
            }
            manager.setAppearanceMode(appearanceMode)
        }
        if let squareSize = preset.squareSize {
            switch squareSize {
            case .small:
                squareSizeControl.selectedSegment = 0
            case .medium:
                squareSizeControl.selectedSegment = 1
            case .large:
                squareSizeControl.selectedSegment = 2
            }
            manager.setSquareSize(squareSize)
        }

        if let animationSpeed = preset.animationSpeed {
            switch animationSpeed {
            case .normal:
                animationSpeedControl.selectedSegment = 1
            case .fast:
                animationSpeedControl.selectedSegment = 0
            case .slow:
                animationSpeedControl.selectedSegment = 2
            }
            manager.setAnimationSpeed(animationSpeed)
        }
        if let color1 = preset.color1 {
            color1Well.color = color1
            manager.setColor(color1, for: .color1)
        }
        if let color2 = preset.color2 {
            color2Well.color = color2
            manager.setColor(color2, for: .color2)
        }
        if let color3 = preset.color3 {
            color3Well.color = color3
            manager.setColor(color3, for: .color3)
        }
    }
}

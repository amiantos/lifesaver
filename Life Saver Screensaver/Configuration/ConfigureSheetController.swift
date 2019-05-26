//
//  ConfigureSheetController.swift
//  Life Saver Screensaver
//
//  Created by Brad Root on 5/21/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Cocoa
import SpriteKit

final class ConfigureSheetController: NSObject {
    private let manager = LifeManager()

    // MARK: - Presets

    fileprivate let presets: [LifeSettings] = lifePresets

    // MARK: - Config Actions and Outlets

    @IBOutlet var window: NSWindow?

    @IBOutlet var stylePresetsButton: NSSegmentedControl!
    @IBAction func stylePresetsAction(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            let simulationSettings = LifeSettings(title: "Simulation", appearanceMode: nil, squareSize: .small, animationSpeed: .fast, color1: nil, color2: nil, color3: nil)
            setupFields(with: simulationSettings)
        case 2:
            let abstractSettings = LifeSettings(title: "Abstract", appearanceMode: nil, squareSize: .large, animationSpeed: .slow, color1: nil, color2: nil, color3: nil)
            setupFields(with: abstractSettings)
        default:
            let defaultSettings = LifeSettings(title: "Defaults", appearanceMode: nil, squareSize: .medium, animationSpeed: .normal, color1: nil, color2: nil, color3: nil)
            setupFields(with: defaultSettings)
        }
    }

    @IBOutlet var presetsButton: NSPopUpButton!
    @IBAction func presetsAction(_ sender: NSPopUpButton) {
        guard let title = sender.titleOfSelectedItem else { return }
        let soughtPreset = presets.filter { $0.title == title }.first
        if let preset = soughtPreset {
            setupFields(with: preset)
        }
    }

    @IBOutlet var appearanceControl: NSSegmentedControl!
    @IBAction func appearanceAction(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 1:
            manager.setAppearanceMode(Appearance.light)
        default:
            manager.setAppearanceMode(Appearance.dark)
        }
    }

    @IBOutlet var squareSizeControl: NSSegmentedControl!
    @IBAction func squareSizeAction(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            manager.setSquareSize(.small)
        case 2:
            manager.setSquareSize(.large)
        default:
            manager.setSquareSize(.medium)
        }
        updateStylePresetsControl()
    }

    @IBOutlet var animationSpeedControl: NSSegmentedControl!
    @IBAction func animationSpeedAction(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            manager.setAnimationSpeed(.fast)
        case 2:
            manager.setAnimationSpeed(.slow)
        default:
            manager.setAnimationSpeed(.normal)
        }
        updateStylePresetsControl()
    }

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

    @IBAction func twitterAction(_: NSButton) {
        URLType.twitter.open()
    }

    @IBAction func gitHubAction(_: NSButton) {
        URLType.github.open()
    }

    @IBAction func bradAction(_: NSButton) {
        URLType.brad.open()
    }

    @IBAction func websiteAction(_: NSButton) {
        URLType.website.open()
    }

    @IBAction func closeConfigureSheet(sender _: AnyObject) {
        guard let window = window else { return }
        window.sheetParent?.endSheet(window)
    }

    // MARK: - View Setup

    override init() {
        super.init()
        let myBundle = Bundle(for: ConfigureSheetController.self)
        myBundle.loadNibNamed("ConfigureSheet", owner: self, topLevelObjects: nil)

        setupFields()
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

        setupPresets()
        updateStylePresetsControl()
    }

    fileprivate func setupPresets() {
        presetsButton.removeAllItems()
        var presetTitles: [String] = []
        for preset in presets {
            presetTitles.append(preset.title)
        }
        presetsButton.addItems(withTitles: presetTitles)
    }

    fileprivate func updateStylePresetsControl() {
        if manager.animationSpeed == .fast, manager.squareSize == .small {
            stylePresetsButton.selectSegment(withTag: 0)
        } else if manager.animationSpeed == .normal, manager.squareSize == .medium {
            stylePresetsButton.selectSegment(withTag: 1)
        } else if manager.animationSpeed == .slow, manager.squareSize == .large {
            stylePresetsButton.selectSegment(withTag: 2)
        } else {
            stylePresetsButton.setSelected(false, forSegment: stylePresetsButton.selectedSegment)
        }
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

//
//  ConfigureSheetController.swift
//  Life Saver Screensaver
//
//  Created by Brad Root on 5/21/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Cocoa
import SpriteKit

final class ConfigureSheetController: NSObject {
    private let manager = LifeManager()

    // MARK: - Presets

    fileprivate let presets: [LifePreset] = colorPresets

    // MARK: - Config Actions and Outlets

    @IBOutlet var window: NSWindow?

    @IBOutlet var stylePresetsButton: NSSegmentedControl!
    @IBAction func stylePresetsAction(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            let simulationSettings = LifePreset(
                title: "Simulation",
                appearanceMode: nil,
                squareSize: .small,
                animationSpeed: .fast,
                deathFade: nil,
                shiftingColors: nil,
                color1: nil,
                color2: nil,
                color3: nil
            )
            loadPreset(simulationSettings)
        case 2:
            let abstractSettings = LifePreset(
                title: "Abstract",
                appearanceMode: nil,
                squareSize: .large,
                animationSpeed: .slow,
                deathFade: nil,
                shiftingColors: nil,
                color1: nil,
                color2: nil,
                color3: nil
            )
            loadPreset(abstractSettings)
        default:
            let defaultSettings = LifePreset(
                title: "Defaults",
                appearanceMode: nil,
                squareSize: .medium,
                animationSpeed: .normal,
                deathFade: nil,
                shiftingColors: nil,
                color1: nil,
                color2: nil,
                color3: nil
            )
            loadPreset(defaultSettings)
        }
    }

    @IBOutlet var presetsButton: NSPopUpButton!
    @IBAction func presetsAction(_ sender: NSPopUpButton) {
        guard let title = sender.titleOfSelectedItem else { return }
        let soughtPreset = presets.filter { $0.title == title }.first
        if let preset = soughtPreset {
            loadPreset(preset)
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
        updateColorPresetsControl()
    }

    @IBOutlet var squareSizeControl: NSSegmentedControl!
    @IBAction func squareSizeAction(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            manager.setSquareSize(.superSmall)
        case 1:
            manager.setSquareSize(.verySmall)
        case 2:
            manager.setSquareSize(.small)
        case 3:
            manager.setSquareSize(.medium)
        case 4:
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
        updateColorPresetsControl()
    }

    @IBOutlet var color2Well: NSColorWell!
    @IBAction func color2Action(_ sender: NSColorWell) {
        manager.setColor(sender.color as SKColor, for: .color2)
        updateColorPresetsControl()
    }

    @IBOutlet var color3Well: NSColorWell!
    @IBAction func color3Action(_ sender: NSColorWell) {
        manager.setColor(sender.color as SKColor, for: .color3)
        updateColorPresetsControl()
    }

    @IBOutlet var randomColorPresetCheck: NSButton!
    @IBAction func randomColorPresetAction(_ sender: NSButtonCell) {
        manager.setRandomColorPreset(sender.state == .on ? true : false)
        updateColorPresetsControl()
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

        randomColorPresetCheck.toolTip = "Enable this to have a random color preset selected each time the screensaver loads."

        loadPresets()
        loadSettings()
    }

    fileprivate func loadSettings() {
        switch manager.appearanceMode {
        case .dark:
            appearanceControl.selectedSegment = 0
        case .light:
            appearanceControl.selectedSegment = 1
        }

        switch manager.squareSize {
        case .superSmall:
            squareSizeControl.selectedSegment = 0
        case .verySmall:
            squareSizeControl.selectedSegment = 1
        case .small:
            squareSizeControl.selectedSegment = 2
        case .medium:
            squareSizeControl.selectedSegment = 3
        case .large:
            squareSizeControl.selectedSegment = 4
        }

        switch manager.animationSpeed {
        case .normal:
            animationSpeedControl.selectedSegment = 1
        case .fast:
            animationSpeedControl.selectedSegment = 0
        case .slow:
            animationSpeedControl.selectedSegment = 2
        case .off:
            animationSpeedControl.selectedSegment = 1
        }

        color1Well.color = manager.color1
        color2Well.color = manager.color2
        color3Well.color = manager.color3

        randomColorPresetCheck.state = manager.randomColorPreset ? .on : .off

        updateStylePresetsControl()
        updateColorPresetsControl()
    }

    fileprivate func loadPresets() {
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

    fileprivate func updateColorPresetsControl() {
        let filteredPresets = presets.filter { $0.color1 == manager.color1 && $0.color2 == manager.color2 && $0.color3 == manager.color3 }
        presetsButton.selectItem(withTitle: filteredPresets.first?.title ?? "Custom")

        presetsButton.isEnabled = !manager.randomColorPreset
        color1Well.isEnabled = !manager.randomColorPreset
        color2Well.isEnabled = !manager.randomColorPreset
        color3Well.isEnabled = !manager.randomColorPreset
        appearanceControl.isEnabled = !manager.randomColorPreset
    }

    fileprivate func loadPreset(_ preset: LifePreset) {
        manager.configure(with: preset)
        loadSettings()
    }
}

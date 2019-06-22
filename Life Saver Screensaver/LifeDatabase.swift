//
//  LifeDatabase.swift
//  Life Saver
//
//  Created by Brad Root on 5/21/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import ScreenSaver
import SpriteKit

struct LifeDatabase {
    fileprivate enum Key {
        static let appearanceMode = "appearanceMode"
        static let squareSize = "squareSize"
        static let blurAmount = "blurAmount"
        static let animationSpeed = "animationSpeed"
        static let color1 = "color1"
        static let color2 = "color2"
        static let color3 = "color3"
        static let randomColorPreset = "randomColorPreset"
    }

    static var standard: ScreenSaverDefaults {
        guard let bundleIdentifier = Bundle(for: LifeManager.self).bundleIdentifier,
            let database = ScreenSaverDefaults(forModuleWithName: bundleIdentifier)
        else { fatalError("Failed to retrieve database") }

        database.register(defaults:
            [Key.appearanceMode: Appearance.dark.rawValue,
             Key.animationSpeed: AnimationSpeed.normal.rawValue,
             Key.squareSize: SquareSize.medium.rawValue,
             Key.color1: archiveData(SKColor.defaultColor1),
             Key.color2: archiveData(SKColor.defaultColor2),
             Key.color3: archiveData(SKColor.defaultColor3),
             Key.randomColorPreset: false])

        return database
    }
}

extension ScreenSaverDefaults {
    var appearanceMode: Appearance {
        return Appearance(rawValue: integer(forKey: LifeDatabase.Key.appearanceMode))!
    }

    func set(appearanceMode: Appearance) {
        set(appearanceMode.rawValue, for: LifeDatabase.Key.appearanceMode)
    }

    var squareSize: SquareSize {
        return SquareSize(rawValue: integer(forKey: LifeDatabase.Key.squareSize))!
    }

    func set(squareSize: SquareSize) {
        set(squareSize.rawValue, for: LifeDatabase.Key.squareSize)
    }

    var animationSpeed: AnimationSpeed {
        return AnimationSpeed(rawValue: integer(forKey: LifeDatabase.Key.animationSpeed))!
    }

    func set(animationSpeed: AnimationSpeed) {
        set(animationSpeed.rawValue, for: LifeDatabase.Key.animationSpeed)
    }

    var randomColorPreset: Bool {
        return bool(forKey: LifeDatabase.Key.randomColorPreset)
    }

    func set(randomColorPreset: Bool) {
        set(randomColorPreset, for: LifeDatabase.Key.randomColorPreset)
    }

    func getColor(_ color: Colors) -> SKColor {
        switch color {
        case .color1:
            return unarchiveColor(data(forKey: LifeDatabase.Key.color1)!)
        case .color2:
            return unarchiveColor(data(forKey: LifeDatabase.Key.color2)!)
        case .color3:
            return unarchiveColor(data(forKey: LifeDatabase.Key.color3)!)
        }
    }

    func set(_ color: SKColor, for colors: Colors) {
        switch colors {
        case .color1:
            set(archiveData(color), for: LifeDatabase.Key.color1)
        case .color2:
            set(archiveData(color), for: LifeDatabase.Key.color2)
        case .color3:
            set(archiveData(color), for: LifeDatabase.Key.color3)
        }
    }
}

private extension ScreenSaverDefaults {
    func set(_ object: Any, for key: String) {
        set(object, forKey: key)
        synchronize()
    }
}

private func archiveData(_ data: Any) -> Data {
    do {
        let data = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
        return data
    } catch {
        fatalError("Failed to archive data")
    }
}

private func unarchiveColor(_ data: Data) -> SKColor {
    do {
        let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SKColor
        return color!
    } catch {
        fatalError("Failed to unarchive data")
    }
}

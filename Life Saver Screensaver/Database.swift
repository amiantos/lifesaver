//
//  Database.swift
//  Life Saver
//
//  Created by Brad Root on 5/21/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import ScreenSaver
import SpriteKit

// MARK: Database

struct Database {
    // MARK: Key

    fileprivate enum Key {
        static let appearanceMode = "appearanceMode"
        static let squareSize = "squareSize"
        static let blurAmount = "blurAmount"
        static let animationSpeed = "animationSpeed"
        static let color1 = "color1"
        static let color2 = "color2"
        static let color3 = "color3"
    }

    // MARK: Properties

    static var standard: ScreenSaverDefaults {
        guard let bundleIdentifier = Bundle(for: LifeSaverManager.self).bundleIdentifier,
            let database = ScreenSaverDefaults(forModuleWithName: bundleIdentifier)
        else { fatalError("Failed to retrieve database") }

        database.register(defaults:
            [Key.appearanceMode: Appearance.dark.rawValue,
             Key.animationSpeed: AnimationSpeed.normal.rawValue,
             Key.squareSize: SquareSize.medium.rawValue,
             Key.color1: archiveData(SKColor.defaultColor1),
             Key.color2: archiveData(SKColor.defaultColor2),
             Key.color3: archiveData(SKColor.defaultColor3)])

        return database
    }
}

// MARK: - ScreenSaverDefaults's Functions

extension ScreenSaverDefaults {
    var appearanceMode: Appearance {
        return Appearance(rawValue: integer(forKey: Database.Key.appearanceMode))!
    }

    func set(appearanceMode: Appearance) {
        set(appearanceMode.rawValue, for: Database.Key.appearanceMode)
    }

    var squareSize: SquareSize {
        return SquareSize(rawValue: integer(forKey: Database.Key.squareSize))!
    }

    func set(squareSize: SquareSize) {
        set(squareSize.rawValue, for: Database.Key.squareSize)
    }

    var animationSpeed: AnimationSpeed {
        return AnimationSpeed(rawValue: integer(forKey: Database.Key.animationSpeed))!
    }

    func set(animationSpeed: AnimationSpeed) {
        set(animationSpeed.rawValue, for: Database.Key.animationSpeed)
    }

    func getColor(_ color: Colors) -> SKColor {
        switch color {
        case .color1:
            return unarchiveColor(data(forKey: Database.Key.color1)!)
        case .color2:
            return unarchiveColor(data(forKey: Database.Key.color2)!)
        case .color3:
            return unarchiveColor(data(forKey: Database.Key.color3)!)
        }
    }

    func set(_ color: SKColor, for colors: Colors) {
        switch colors {
        case .color1:
            set(archiveData(color), for: Database.Key.color1)
        case .color2:
            set(archiveData(color), for: Database.Key.color2)
        case .color3:
            set(archiveData(color), for: Database.Key.color3)
        }
    }
}

// MARK: - ScreenSaverDefaults's Private Functions

private extension ScreenSaverDefaults {
    func set(_ object: Any, for key: String) {
        set(object, forKey: key)
        synchronize()
    }
}

func archiveData(_ data: Any) -> Data {
    do {
        let data = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
        return data
    } catch {
        fatalError("Failed to archive data")
    }
}

func unarchiveColor(_ data: Data) -> SKColor {
    do {
        let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SKColor
        return color!
    } catch {
        fatalError("Failed to unarchive data")
    }
}

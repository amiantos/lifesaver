//
//  Extensions.swift
//  Life Saver
//
//  Created by Bradley Root on 6/29/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import SpriteKit

extension SKColor {
    func modified(withAdditionalHue hue: CGFloat, additionalSaturation: CGFloat, additionalBrightness: CGFloat) -> SKColor {
        var currentHue: CGFloat = 0.0
        var currentSaturation: CGFloat = 0.0
        var currentBrigthness: CGFloat = 0.0
        var currentAlpha: CGFloat = 0.0

        #if os(macOS)
        // On macOS, NSColor must be converted to a compatible color space before extracting HSB
        guard let rgbColor = usingColorSpace(.deviceRGB) else {
            return self
        }
        rgbColor.getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentAlpha)
        #else
        guard getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentAlpha) else {
            return self
        }
        #endif

        return SKColor(
            hue: currentHue + hue > 1 ? hue : currentHue + hue,
            saturation: currentSaturation + additionalSaturation,
            brightness: currentBrigthness + additionalBrightness,
            alpha: currentAlpha
        )
    }
}

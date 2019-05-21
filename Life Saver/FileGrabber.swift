//
//  FileGrabber.swift
//  Life Saver
//
//  Created by Brad Root on 5/21/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import SpriteKit

#if os(macOS)
    import Cocoa

    // Step 1: Typealias UIImage to NSImage
    typealias UIImage = NSImage
#endif

class FileGrabber {
    let bundle: Bundle

    static let shared: FileGrabber = FileGrabber()

    init() {
        let bundle = Bundle(for: LifeScene.self)
        self.bundle = bundle
    }

    public func getSKTexture(named: String) -> SKTexture? {
        #if os(macOS)
            guard let image = bundle.image(forResource: named) else { return nil }
        #else
            guard let image = UIImage(named: named, in: bundle, compatibleWith: nil) else { return nil }
        #endif
        return SKTexture(image: image)
    }
}

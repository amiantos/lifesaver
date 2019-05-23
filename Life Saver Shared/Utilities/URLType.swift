//
//  URLType.swift
//  Life Saver Screensaver
//
//  Created by Brad Root on 5/22/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Cocoa

enum URLType: String {
    case brad = "https://amiantos.net"
    case github = "https://github.com/amiantos/lifesaver"
    case twitter = "https://twitter.com/amiantos"
    case website = "https://amiantos.net/lifesaver"
}

extension URLType {
    func open() {
        guard let url = URL(string: rawValue) else { return }
        NSWorkspace.shared.open(url)
    }
}

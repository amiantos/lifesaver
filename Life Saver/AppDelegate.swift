//
//  AppDelegate.swift
//  Life Saver
//
//  Created by Brad Root on 4/12/26.
//  Copyright © 2026 Brad Root. All rights reserved.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let window else { return }
        let hosting = NSHostingView(rootView: HostContentView())
        window.contentView = hosting
        window.title = "Life Saver"
        window.setContentSize(NSSize(width: 980, height: 640))
        window.center()
        window.makeKeyAndOrderFront(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }
}

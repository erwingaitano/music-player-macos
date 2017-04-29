//
//  AppDelegate.swift
//  music-player-macos
//
//  Created by Erwin GO on 4/28/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let minWidth: CGFloat = 800
        let minHeight: CGFloat = 600
        
        window.setFrame(NSMakeRect(0, 0, minWidth, minHeight), display: true)
        window.isOpaque = false
        window.isMovable = true
        window.showsResizeIndicator = true
        window.center()
        window.styleMask.insert([.closable, .titled, .resizable, .miniaturizable])
        window.title = "Music Player"
        window.minSize = NSSize(width: minWidth, height: minHeight)
        window.titlebarAppearsTransparent = false
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        guard let mainWindowContentView = window.contentView else { return }
        let mainController = MainController()
        mainWindowContentView.addSubview(mainController.view)
        mainController.view.allEdgeAnchorsToEqual(mainWindowContentView)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

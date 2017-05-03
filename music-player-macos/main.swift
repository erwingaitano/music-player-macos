//
//  AppDelegate.swift
//  music-player-macos
//
//  Created by Erwin GO on 4/28/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    //    @IBOutlet weak var window: NSWindow!
    private var window = NSWindow()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let minWidth: CGFloat = 800
        let minHeight: CGFloat = 600
        
        window.setFrame(NSMakeRect(0, 0, minWidth, minHeight), display: true)
        window.isOpaque = false
        window.isMovable = true
        window.showsResizeIndicator = true
        window.center()
        window.styleMask.insert([.closable, .titled, .resizable, .miniaturizable, .fullSizeContentView])
        window.title = ""
        window.titlebarAppearsTransparent = true
        window.contentMinSize = NSSize(width: minWidth, height: minHeight)
        window.minSize = NSSize(width: minWidth, height: minHeight)
        window.minFullScreenContentSize = NSSize(width: minWidth, height: minHeight)
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
    
    // MARK: - API Methods

    public static func handleMenuPlayPauseFired() {
        NotificationCenter.default.post(name: .customMenuPlayPauseFired, object: nil)
    }
    
    public static func handleMenuPreviousFired() {
        NotificationCenter.default.post(name: .customMenuPreviousFired, object: nil)
    }
    
    public static func handleMenuNextFired() {
        NotificationCenter.default.post(name: .customMenuNextFired, object: nil)
    }
    
    public static func handleMenuIncreaseVolumeFired() {
        NotificationCenter.default.post(name: .customMenuIncreaseVolumeFired, object: nil)
    }
    
    public static func handleMenuDecreaseVolumeFired() {
        NotificationCenter.default.post(name: .customMenuDecreaseVolumeFired, object: nil)
    }
    
    public static func handleMenuRepeatFired() {
        NotificationCenter.default.post(name: .customMenuRepeatFired, object: nil)
    }
    
    public static func handleMenuShuffleFired() {
        NotificationCenter.default.post(name: .customMenuShuffleFired, object: nil)
    }
}

func makeMainMenu() -> NSMenu {
    let mainMenu = NSMenu() // `title` really doesn't matter.
    let mainAppMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    let mainControlsMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    mainMenu.addItem(mainAppMenuItem)
    mainMenu.addItem(mainControlsMenuItem)
    
    let appMenu = NSMenu()
    mainAppMenuItem.submenu = appMenu
    appMenu.addItem(withTitle: "About Me", action: nil, keyEquivalent: "")
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(withTitle: "Preferences...", action: nil, keyEquivalent: ",")
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(withTitle: "Hide Me", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
    appMenu.addItem({ () -> NSMenuItem in
        let v = NSMenuItem(title: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")
        v.keyEquivalentModifierMask = []
        return v
        }())
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(withTitle: "Quit Me", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    
    let mainControlsMenu = NSMenu(title: "Controls")
    mainControlsMenuItem.submenu = mainControlsMenu
    mainControlsMenu.addItem({ () -> NSMenuItem in
        let v = NSMenuItem(title: "Play/Pause", action: #selector(AppDelegate.handleMenuPlayPauseFired), keyEquivalent: " ")
        v.target = AppDelegate.self
        v.keyEquivalentModifierMask = []
        return v
    }())
    mainControlsMenu.addItem({ () -> NSMenuItem in
        let v = NSMenuItem(title: "Previous", action: #selector(AppDelegate.handleMenuPreviousFired), keyEquivalent: NSString(characters: [unichar(NSLeftArrowFunctionKey)], length: 1) as String)
        v.target = AppDelegate.self
        return v
    }())
    mainControlsMenu.addItem({ () -> NSMenuItem in
        let v = NSMenuItem(title: "Next", action: #selector(AppDelegate.handleMenuNextFired), keyEquivalent: NSString(characters: [unichar(NSRightArrowFunctionKey)], length: 1) as String)
        v.target = AppDelegate.self
        return v
    }())
    
    mainControlsMenu.addItem(NSMenuItem.separator())
    
    mainControlsMenu.addItem({ () -> NSMenuItem in
        let v = NSMenuItem(title: "Increase Volume", action: #selector(AppDelegate.handleMenuIncreaseVolumeFired), keyEquivalent: NSString(characters: [unichar(NSUpArrowFunctionKey)], length: 1) as String)
        v.target = AppDelegate.self
        return v
    }())
    mainControlsMenu.addItem({ () -> NSMenuItem in
        let v = NSMenuItem(title: "Decrease Volume", action: #selector(AppDelegate.handleMenuDecreaseVolumeFired), keyEquivalent: NSString(characters: [unichar(NSDownArrowFunctionKey)], length: 1) as String)
        v.target = AppDelegate.self
        return v
    }())
    
    mainControlsMenu.addItem(NSMenuItem.separator())

    mainControlsMenu.addItem({ () -> NSMenuItem in
        let v = NSMenuItem(title: "Repeat", action: #selector(AppDelegate.handleMenuRepeatFired), keyEquivalent: "r")
        v.target = AppDelegate.self
        v.keyEquivalentModifierMask = []
        return v
    }())
    mainControlsMenu.addItem({ () -> NSMenuItem in
        let v = NSMenuItem(title: "Shuffle", action: #selector(AppDelegate.handleMenuShuffleFired), keyEquivalent: "s")
        v.target = AppDelegate.self
        v.keyEquivalentModifierMask = []
        return v
    }())
    
    return mainMenu
}

// For some unknown reason u have to start the delegate before making the menu
// also can't set the delegate before the setting the mainMenu lol
let del = AppDelegate()
NSApplication.shared().mainMenu = makeMainMenu()
NSApplication.shared().delegate = del
NSApplication.shared().run()

//
//  Button.swift
//  music-player-macos
//
//  Created by Erwin GO on 4/29/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

class Button: NSButton {
    // MARK: - Inits

    init() {
        super.init(frame: .zero)
        wantsLayer = true
        isBordered = false
        imageScaling = .scaleProportionallyDown
        layer?.backgroundColor = CGColor.clear
        setButtonType(NSButtonType.momentaryChange)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

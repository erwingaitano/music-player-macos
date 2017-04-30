//
//  Label.swift
//  music-player-macos
//
//  Created by Erwin GO on 4/29/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

class Label: NSTextField {
    // MARK: - Inits

    init() {
        super.init(frame: .zero)
        isEditable = false
        isBordered = false
        backgroundColor = .clear
        textColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

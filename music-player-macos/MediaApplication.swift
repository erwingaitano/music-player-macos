//
//  MediaApplication.swift
//  music-player-mac
//
//  Created by Erwin GO on 4/28/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

@objc(MediaApplication)
class MediaApplication: NSApplication {
    override func sendEvent(_ event: NSEvent) {
        if (event.type == .systemDefined && event.subtype.rawValue == 8) {
            let keyCode = ((event.data1 & 0xFFFF0000) >> 16)
            let keyFlags = (event.data1 & 0x0000FFFF)
            // Get the key state. 0xA is KeyDown, OxB is KeyUp
            let keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA
            let keyRepeat = (keyFlags & 0x1)
            mediaKeyEvent(key: Int32(keyCode), state: keyState, keyRepeat: Bool(NSNumber(value: keyRepeat)))
        }
        
        super.sendEvent(event)
    }
    
    func mediaKeyEvent(key: Int32, state: Bool, keyRepeat: Bool) {
        // Only send events on KeyDown. Without this check, these events will happen twice
        Swift.print(1111111111)
        if (state) {
            switch(key) {
            case NX_KEYTYPE_PLAY:
                NotificationCenter.default.post(name: .customPlayPauseMediaKeyPressed, object: nil)
                break
            case NX_KEYTYPE_FAST:
                NotificationCenter.default.post(name: .customFastForwardMediaKeyPressed, object: nil)
                break
            case NX_KEYTYPE_REWIND:
                NotificationCenter.default.post(name: .customFastBackwardMediaKeyPressed, object: nil)
                break
            default:
                break
            }
        }
    }
}

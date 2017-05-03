//
//  ImageExtensions.swift
//  music-player-macos
//
//  Created by Erwin GO on 5/2/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

extension NSImage {
    func imageWithTintColor(tintColor: NSColor) -> NSImage {
        let isTemplate = self.isTemplate
        self.isTemplate = true
        
        let image = self.copy() as! NSImage
        image.lockFocus()
        
        tintColor.set()
        NSRectFillUsingOperation(NSMakeRect(0, 0, image.size.width, image.size.height), .sourceAtop)
        image.unlockFocus()
        
        self.isTemplate = isTemplate
        image.isTemplate = false
        return image
    }
}

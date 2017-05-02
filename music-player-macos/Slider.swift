//
//  Slider.swift
//  music-player-macos
//
//  Created by Erwin GO on 5/2/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

class Slider: NSSlider {
    // MARK: - Inits
    
    init() {
        super.init(frame: .zero)
        cell = SliderCell()
        wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SliderCell: NSSliderCell {
    // MARK: - Properties

    private var trackColor = NSColor.hexStringToColor(hex: "#555555")
    
    // MARK: - Inits

    override init() {
        super.init()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    override func drawBar(inside rect: NSRect, flipped: Bool) {
        var rect = rect
        rect.size.height = CGFloat(5)
        let barRadius = CGFloat(2.5)
        
        var value = CGFloat((self.doubleValue - self.minValue) / (self.maxValue - self.minValue))
        if value.isNaN { value = 0 }
        
        let finalWidth = CGFloat(value * (self.controlView!.frame.size.width - 8))
        var leftRect = rect
        leftRect.size.width = finalWidth
        
        let bg = NSBezierPath(roundedRect: rect, xRadius: barRadius, yRadius: barRadius)
        trackColor.setFill()
        bg.fill()
        
        let active = NSBezierPath(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
        NSColor.secondaryColor.setFill()
        active.fill()
    }
}

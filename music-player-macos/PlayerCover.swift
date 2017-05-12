//
//  PlayerCover.swift
//  music-player-mac
//
//  Created by Erwin GO on 4/28/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

class PlayerCover: View {
    // MARK: - Properties
    
    private let coverGradientEl = CAGradientLayer()
    private var coverCyclerEl: PlayerCoverCycler?
    
    private lazy var imageViewEl: ImageView = {
        let v = ImageView()
        v.backgroundSize = .none
        return v
    }()
    
    // MARK: - Inits
    
    override init() {
        super.init(frame: .zero)
        coverGradientEl.colors = [NSColor.black.withAlphaComponent(0.9).cgColor, NSColor.black.withAlphaComponent(0.75).cgColor]
        coverGradientEl.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        layer?.backgroundColor = NSColor.hexStringToColor(hex: "#aaaaaa").cgColor
        layer?.addSublayer(self.coverGradientEl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API Methods
    
    public func setCovers(_ coverUrls: [String]) {
        subviews.forEach({ $0.removeFromSuperview() })
        coverCyclerEl?.stopAnimations()
        
        if coverUrls.count == 0 {
            return
        }

        coverCyclerEl = PlayerCoverCycler(coverUrls, containerSize: frame.size)
        coverCyclerEl!.startAnimations()
        addSubview(coverCyclerEl!)
        coverCyclerEl!.allEdgeAnchorsToEqual(self)
    }
}

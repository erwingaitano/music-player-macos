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
    
    private var coversToRotate: Int!
    private var coverUrls: [String]!
    private var coverToRotateIdx: Int!
    private let coverGradientEl = CAGradientLayer()
    private var coverRotationTimer: Timer?
    private lazy var imageViewEl: NSImageView = {
        let v = NSImageView()
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.hexStringToColor(hex: "#aaaaaa").cgColor
        
        self.coverGradientEl.colors = [NSColor.black.withAlphaComponent(0.9).cgColor, NSColor.black.withAlphaComponent(0.75).cgColor]
        self.coverGradientEl.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        v.layer?.addSublayer(self.coverGradientEl)
        return v
    }()
    
    // MARK: - Inits
    
    override init() {
        super.init(frame: .zero)
        
        addSubview(imageViewEl)
        imageViewEl.allEdgeAnchorsToEqual(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeCoverRotationTimer()
    }
    
    // MARK: - Private Methods
    
    private func changeCover(shouldRemoveCover: Bool = false) {
        imageViewEl.kf.cancelDownloadTask()
        
        if shouldRemoveCover {
            self.imageViewEl.layer?.addSublayer(self.coverGradientEl)
            self.imageViewEl.image = nil
            return
        }
        
        imageViewEl.kf.setImage(with: URL(string: GeneralHelpers.getCoverUrl(coverUrls[coverToRotateIdx])), placeholder: self.imageViewEl.image, completionHandler: { (image, error, _, _) in
            if image != nil && error == nil {
                self.coverGradientEl.removeFromSuperlayer()
            } else {
                self.imageViewEl.layer?.addSublayer(self.coverGradientEl)
            }
        })
    }
    
    @objc private func handleCoverTimer() {
        coverToRotateIdx = coverToRotateIdx + 1
        if coverToRotateIdx >= coversToRotate { coverToRotateIdx = 0 }
        changeCover()
    }
    
    private func removeCoverRotationTimer() {
        coverRotationTimer?.invalidate()
        coverRotationTimer = nil
    }
    
    // MARK: - API Methods
    
    public func setCovers(_ coverUrls: [String]) {
        self.coverUrls = coverUrls
        coversToRotate = coverUrls.count
        coverToRotateIdx = 0
        removeCoverRotationTimer()
        
        if coversToRotate == 0 {
            changeCover(shouldRemoveCover: true)
            return
        }
        
        changeCover()
        coverRotationTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(handleCoverTimer), userInfo: nil, repeats: true)
    }
}

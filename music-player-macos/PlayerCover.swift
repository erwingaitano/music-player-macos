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
        if shouldRemoveCover {
            self.imageViewEl.image = nil
            return
        }
        
        if let image = NSImage(byReferencingFile: GeneralHelpers.getCoverUrl(coverUrls[coverToRotateIdx])) {
            imageViewEl.image = image
            
            
            var newImageViewSize = GeneralHelpers.getRealImageSize(image)
            newImageViewSize = GeneralHelpers.getImageSizeToCoverContainer(imageSize: newImageViewSize, containerSize: frame.size)
            imageViewEl.layer?.removeAllAnimations()
            imageViewEl.frame.size = newImageViewSize
            
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 1
            animation.toValue = 0.3
            animation.duration = 3
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeForwards
            imageViewEl.layer?.add(animation, forKey: "opacity")
            
            if newImageViewSize.width > frame.size.width {
                let animation = CABasicAnimation(keyPath: "transform.translation.x")
                animation.fromValue = 0
                animation.toValue = frame.size.width - newImageViewSize.width
                animation.duration = 3
                animation.isRemovedOnCompletion = false
                animation.fillMode = kCAFillModeForwards
                imageViewEl.layer?.add(animation, forKey: "translateAnimation")
            } else if newImageViewSize.height > frame.size.height {
                let animation = CABasicAnimation(keyPath: "transform.translation.y")
                animation.fromValue = 0
                animation.toValue = frame.size.height - newImageViewSize.height
                animation.duration = 3
                animation.isRemovedOnCompletion = false
                animation.fillMode = kCAFillModeForwards
                imageViewEl.layer?.add(animation, forKey: "translateAnimation")
            } else {
                
            }
        }
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
        } else if coversToRotate == 1 {
            changeCover()
            return
        }
        
        changeCover()
        coverRotationTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(handleCoverTimer), userInfo: nil, repeats: true)
    }
}

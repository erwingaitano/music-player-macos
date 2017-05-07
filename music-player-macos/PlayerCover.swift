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
    
    private var coverUrls: [String]!
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
    
    // MARK: - Private Methods
    
    private func startAnimatingCover() {
        self.subviews.forEach({ $0.removeFromSuperview() })
        coverCyclerEl?.stopAnimations()

        if coverUrls.count == 0 {
            return
        } else if coverUrls.count == 1 {
            addSubview(imageViewEl)
            if let image = NSImage(byReferencingFile: GeneralHelpers.getCoverUrl(coverUrls[0])) {
                imageViewEl.image = image
                var newImageViewSize = GeneralHelpers.getRealImageSize(image)
                newImageViewSize = GeneralHelpers.getImageSizeToCoverContainer(imageSize: newImageViewSize, containerSize: frame.size)
                imageViewEl.frame.size = newImageViewSize
                image.size = newImageViewSize
            }
        } else {
            var chainAnimationsItems: [PlayerCoverCycler.ChainAnimationItem] = []
            
            coverUrls.enumerated().forEach({ (i, url) in
                guard let image = NSImage(byReferencingFile: GeneralHelpers.getCoverUrl(url)) else { return }
                var animations: [PlayerCoverCycler.AnimationItem] = []
                let v = ImageView()
                v.backgroundSize = .none
                v.imageScaling = .scaleNone
                v.image = image
                
                var newImageViewSize = GeneralHelpers.getRealImageSize(image)
                newImageViewSize = GeneralHelpers.getImageSizeToCoverContainer(imageSize: newImageViewSize, containerSize: frame.size)
                v.frame.size = newImageViewSize
                image.size = newImageViewSize

                if newImageViewSize.width > frame.size.width {
                    let animation = CABasicAnimation(keyPath: "transform.translation.x")
                    animation.fromValue = 0
                    animation.toValue = frame.size.width - newImageViewSize.width
                    animation.duration = 5
                    animations.append((animation, "transform.translation.x", nil))
                } else if newImageViewSize.height > frame.size.height {
                    let animation = CABasicAnimation(keyPath: "transform.translation.y")
                    animation.fromValue = 0
                    animation.toValue = frame.size.height - newImageViewSize.height
                    animation.duration = 5
                    animations.append((animation, "transform.translation.y", nil))
                }
                
                let animation = CABasicAnimation(keyPath: "opacity")
                animation.fromValue = 1
                animation.toValue = 0
                animation.duration = 1
                animations.append((animation, "opacity", 4))
                
                chainAnimationsItems.append((v, animations))
            })
            
            coverCyclerEl = PlayerCoverCycler(chainAnimationsItems)
            coverCyclerEl!.startAnimations()
            addSubview(coverCyclerEl!)
            coverCyclerEl!.allEdgeAnchorsToEqual(self)
        }
    }
    
    // MARK: - API Methods
    
    public func setCovers(_ coverUrls: [String]) {
        self.coverUrls = coverUrls
        startAnimatingCover()
    }
}

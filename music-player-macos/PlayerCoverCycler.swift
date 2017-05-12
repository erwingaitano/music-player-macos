//
//  PlayerCoverCycler.swift
//  music-player-macos
//
//  Created by Erwin GO on 5/6/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

class PlayerCoverCycler: View {
    // MARK: - Typealiases

    typealias AnimationItem = (animation: CABasicAnimation, key: String, wholeDuration: Double)
    typealias ChainAnimationItem = (view: ImageView, animations: [AnimationItem])
    
    // MARK: - Properties

    private var shouldCancelCompletionBlock = false
    private var items: [ChainAnimationItem] = []
    
    // MARK: - Inits

    init(_ coverUrls: [String], containerSize: CGSize) {
        super.init()

        coverUrls.forEach({ url in
            guard let image = NSImage(byReferencingFile: GeneralHelpers.getCoverUrl(url)) else { return }
            var animations: [AnimationItem] = []
            let v = ImageView()
            v.backgroundSize = .none
            v.imageScaling = .scaleNone
            v.image = image
            v.isHidden = true
            v.layer?.backgroundColor = NSColor.red.cgColor
            self.addSubview(v)
            
            var newImageViewSize = GeneralHelpers.getRealImageSize(image)
            newImageViewSize = GeneralHelpers.getImageSizeToCoverContainer(imageSize: newImageViewSize, containerSize: containerSize)
            v.frame.size = newImageViewSize
            image.size = newImageViewSize
            
            if newImageViewSize.width > containerSize.width {
                let animation = CABasicAnimation(keyPath: "transform.translation.x")
                animation.fromValue = 0
                animation.toValue = containerSize.width - newImageViewSize.width
                animation.duration = 15
                if coverUrls.count == 1 {
                    animation.repeatCount = Float.infinity
                    animation.autoreverses = true
                }
                animations.append((animation, "transform.translation.x", 15))
            } else if newImageViewSize.height > containerSize.height {
                let animation = CABasicAnimation(keyPath: "transform.translation.y")
                animation.fromValue = 0
                animation.toValue = containerSize.height - newImageViewSize.height
                animation.duration = 15
                if coverUrls.count == 1 {
                    animation.repeatCount = Float.infinity
                    animation.autoreverses = true
                }
                animations.append((animation, "transform.translation.y", 15))
            }
            
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = 2
            animations.append((animation, "opacity", 15))
            
            items.append((v, animations))
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API Methods

    public func startAnimations() {
        let view = subviews[0]
        view.layer?.removeAllAnimations()
        view.isHidden = true
        addSubview(view, positioned: .above, relativeTo: nil)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            // self.items.count == 1 check to prevent infinite loop because it will always trigger
            // this immediately if only one view to animate
            if self.shouldCancelCompletionBlock || self.items.count == 1 {
                CATransaction.setCompletionBlock(nil)
                return
            }

            self.startAnimations()
        }
        
        let item = items.first(where: { $0.view == view })!
        var maxDuration: Double = 0
        
        item.animations.forEach { el in
            el.animation.isRemovedOnCompletion = false
            el.animation.fillMode = kCAFillModeForwards
            if el.wholeDuration > maxDuration { maxDuration = el.wholeDuration }
            view.layer?.add(el.animation, forKey: el.key)
        }
        
        let animationDurationEl = CABasicAnimation(keyPath: "lul")
        animationDurationEl.duration = maxDuration
        view.layer?.add(animationDurationEl, forKey: "lul")
        view.isHidden = false
        
        CATransaction.commit()
    }
    
    public func stopAnimations() {
        shouldCancelCompletionBlock = true
    }
}

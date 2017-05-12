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
    private var items: [ChainAnimationItem]!
    
    // MARK: - Inits

    init(_ items: [ChainAnimationItem]) {
        super.init()
        self.items = items
        self.items.forEach { item in
            self.addSubview(item.view)
            item.view.isHidden = true
        }
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
            if self.shouldCancelCompletionBlock {
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

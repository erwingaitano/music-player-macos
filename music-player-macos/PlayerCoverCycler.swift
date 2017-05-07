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

    typealias AnimationItem = (animation: CABasicAnimation, key: String, delay: Double?)
    typealias ChainAnimationItem = (view: ImageView, animations: [AnimationItem])
    
    // MARK: - Properties

    private var shouldCancelCompletionBlock = false
    private var items: [ChainAnimationItem]!
    
    // MARK: - Inits

    init(_ items: [ChainAnimationItem]) {
        super.init()
        self.items = items
        self.items.enumerated().forEach { (i, item) in
            self.addSubview(item.view, positioned: .below, relativeTo: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API Methods

    public func startAnimations() {
        Swift.print("Rotating")
        let view = subviews[items.count - 1]

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            if self.shouldCancelCompletionBlock {
                CATransaction.setCompletionBlock(nil)
                return
            }
            // this will switch positions in the subviews
            self.addSubview(view, positioned: .below, relativeTo: nil)
            view.layer?.removeAllAnimations()

            self.startAnimations()
        }
        
        // Force to keep last state of animation, it will be removed
        // in the completionBlock to avoid glitches
        let item = items.first(where: { $0.view == view })!
        item.animations.forEach { el in
            el.animation.isRemovedOnCompletion = false
            el.animation.fillMode = kCAFillModeForwards
            if let delay = el.delay { el.animation.beginTime = CACurrentMediaTime() + delay }
            view.layer?.add(el.animation, forKey: el.key)
        }
        
        CATransaction.commit()
    }
    
    public func stopAnimations() {
        shouldCancelCompletionBlock = true
    }
}

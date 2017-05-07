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

    typealias ChainAnimationItem = (view: ImageView, animation: CABasicAnimation, key: String, delay: CGFloat)
    
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
        let item = items[items.count - 1]
        let view = self.subviews[items.count - 1]

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
        item.animation.isRemovedOnCompletion = false
        item.animation.fillMode = kCAFillModeForwards
        view.layer?.add(item.animation, forKey: item.key)
        CATransaction.commit()
    }
    
    public func stopAnimations() {
        shouldCancelCompletionBlock = true
    }
}

//
//  Slideshower.swift
//  music-player-macos
//
//  Created by Erwin GO on 5/12/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

class Slideshower: View {
    // MARK: - Properties

    private var coverCyclerEl: PlayerCoverCycler?
    private var coverContainerEl = View()
    private var lyricsItems: [(view: NSTextView, heightAnchor: NSLayoutConstraint, time: Int)] = []
    private let lyricsTextContainerHeight: CGFloat = 450
    
    private var subtitleContainerEl: View = {
        let v = View()
        v.layer?.backgroundColor = NSColor.black.cgColor
        v.layer?.opacity = 0.5
        return v
    }()
    
//    private var subtitleScrollerEl: View = {
//        let v = View()
//        v.layer?.backgroundColor = NSColor.clear.cgColor
////        v.hasVerticalScroller = true
////        v.drawsBackground = false
//        return v
//    }()
    
    private var subtitleStackContainerEl: View = {
        let v = View()
        v.layer?.backgroundColor = NSColor.clear.cgColor
        return v
    }()
    
    private var subtitleStackEl: View = {
        let v = View()
        v.layer?.backgroundColor = NSColor.clear.cgColor
        return v
    }()
    
    // MARK: - Inits

    override init() {
        super.init()
        layer?.backgroundColor = NSColor.black.cgColor
        let lyricsFileUrl = URL(fileURLWithPath: "/Users/erwin/Music/music-player-files/_media/_artists/Adele/Someone Like You/_lyrics.txt")
        let lyrics = try! String.init(contentsOf: lyricsFileUrl)
        
        
        lyrics.components(separatedBy: "\n\n").forEach { el in
            let tv = NSTextView()
            var elComponents = el.components(separatedBy: "\n")
            let timeComponents = elComponents.removeFirst().components(separatedBy: ":")
            let time = Int(timeComponents[0])! * 60 + Int(timeComponents[1])!
            
            tv.isEditable = false
            tv.isSelectable =  false
            tv.alignment = .center
            tv.backgroundColor = .clear
            tv.textColor = .white
            tv.frame.size.height = 300
            tv.font = NSFont.systemFont(ofSize: 30)
            let heightAnchor = tv.heightAnchorToEqualGet(height: 10)
            tv.string = elComponents.joined(separator: "\n")
            self.lyricsItems.append((tv, heightAnchor, time))
        }

        lyricsItems.enumerated().forEach { (i, el) in
            subtitleStackEl.addSubview(el.view)
            el.view.setContentHuggingPriority(NSLayoutPriorityFittingSizeCompression - 1, for: .vertical)
            el.view.leftAnchorToEqual(subtitleStackEl.leftAnchor)
            el.view.rightAnchorToEqual(subtitleStackEl.rightAnchor)

            if i == 0 {
                el.view.topAnchorToEqual(subtitleStackEl.topAnchor)
            } else {
                el.view.topAnchorToEqual(lyricsItems[i - 1].view.bottomAnchor)
            }

            if i == lyricsItems.count - 1 {
                subtitleStackEl.bottomAnchorToEqual(el.view.bottomAnchor)
            }
        }

        addSubview(coverContainerEl)
        coverContainerEl.widthAnchorToEqual(anchor: coverContainerEl.heightAnchor)
        coverContainerEl.topAnchorToEqual(topAnchor)
        coverContainerEl.bottomAnchorToEqual(bottomAnchor)
        coverContainerEl.leftAnchorToEqual(leftAnchor)
        
        addSubview(subtitleContainerEl)
        subtitleContainerEl.widthAnchorToEqual(width: 500)
        subtitleContainerEl.topAnchorToEqual(topAnchor)
        subtitleContainerEl.bottomAnchorToEqual(bottomAnchor)
        subtitleContainerEl.rightAnchorToEqual(rightAnchor)
        
        subtitleStackContainerEl.addSubview(subtitleStackEl)
        subtitleStackEl.allEdgeAnchorsExceptBottomToEqual(subtitleStackContainerEl)
        
        addSubview(subtitleStackContainerEl)
        subtitleStackContainerEl.heightAnchorToEqual(height: lyricsTextContainerHeight)
        subtitleStackContainerEl.centerYAnchorToEqual(subtitleContainerEl.centerYAnchor)
        subtitleStackContainerEl.leftAnchorToEqual(subtitleContainerEl.leftAnchor)
        subtitleStackContainerEl.rightAnchorToEqual(subtitleContainerEl.rightAnchor)
        
        let vvv = View()
        addSubview(vvv)
        vvv.layer?.backgroundColor = NSColor.red.cgColor
        vvv.heightAnchorToEqual(height: 2)
        vvv.centerYAnchorToEqual(centerYAnchor)
        vvv.leftAnchorToEqual(leftAnchor)
        vvv.rightAnchorToEqual(rightAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods

    private func updateHeightConstraintsForTextViews() {
        lyricsItems.forEach { (view, anchor, _) in
            anchor.constant = view.frame.height
        }
    }
    
    // MARK: - API Methods

    public func startShow(_ coverUrls: [String]) {
        coverContainerEl.subviews.forEach({ $0.removeFromSuperview() })
        coverCyclerEl?.stopAnimations()
        
        if coverUrls.count == 0 {
            return
        }
        
        coverCyclerEl = PlayerCoverCycler(coverUrls, containerSize: coverContainerEl.frame.size)
        coverCyclerEl!.startAnimations()
        coverContainerEl.addSubview(coverCyclerEl!)
        coverCyclerEl!.allEdgeAnchorsToEqual(coverContainerEl)
    }
    
    public func syncSubtitles(withCurrentTime time: Double) {
        let time = Int(time)
        let lastIndex = lyricsItems.count - 1
        var index: Int
        let lyricsItem = lyricsItems.enumerated().first { (i, el) -> Bool in
            if (i < lastIndex && lyricsItems[i + 1].time >= time) || i == lastIndex {
                index = i
                return true
            }
            
            return false
        }

        guard let newLyricsItem = lyricsItem?.element else { return }
        
        
        updateHeightConstraintsForTextViews()
        let itemHeight = newLyricsItem.view.frame.height
        let newYPos = (newLyricsItem.view.frame.origin.y + itemHeight) - subtitleStackEl.frame.height + (subtitleStackContainerEl.frame.height / 2) - (itemHeight / 2)
        subtitleStackEl.animator().setBoundsOrigin(NSPoint(x: 0, y: newYPos))
    }
}

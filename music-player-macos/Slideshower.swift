//
//  Slideshower.swift
//  music-player-macos
//
//  Created by Erwin GO on 5/12/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa
import Dollar

class Slideshower: View {
    // MARK: - Properties

    private var coverCyclerEl: PlayerCoverCycler?
    private var coverContainerEl = View()
    private var lyricsItems: [(view: NSTextView, heightAnchor: NSLayoutConstraint, time: Int)] = []
    private let lyricsTextContainerHeight: CGFloat = 450
    private var idxOfSubtitleItemShowing: Int?
    private var coverUrls: [String] = []
    
    private lazy var updateCoverCyclerDebounced: () -> Void = {
        return $.debounce(delayBy: .milliseconds(10)) { self.updateCoverCycler() }
    }()
    
    private let subtitleContainerGradientEl: CAGradientLayer = {
        let v = CAGradientLayer()
        v.startPoint = CGPoint(x: 1, y: 0)
        v.endPoint = CGPoint(x: 0, y: 0)
        v.colors = [
            NSColor.black.withAlphaComponent(0.9).cgColor,
            NSColor.black.withAlphaComponent(0.75).cgColor,
            NSColor.black.withAlphaComponent(0.5).cgColor,
            NSColor.black.withAlphaComponent(0).cgColor
        ]
        v.locations = [0, 0.8, 0.95, 1]
        return v
    }()
    
    private lazy var subtitleContainerEl: View = {
        let v = View()
        v.layer?.addSublayer(self.subtitleContainerGradientEl)
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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycles

    override func layout() {
        super.layout()
        updateCoverCyclerDebounced()
        subtitleContainerGradientEl.frame = subtitleContainerEl.bounds
        updateHeightConstraintsForTextViews()
    }
    
    // MARK: - Private Methods

    private func updateHeightConstraintsForTextViews() {
        $.delay(by: .milliseconds(50)) {
            self.lyricsItems.forEach { (view, anchor, _) in
                view.textContainerInset = NSSize(width: 10, height: 15)
                anchor.constant = view.frame.height
            }
        }
    }
    
    private func updateCoverCycler() {
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
    
    private func removeSubtitles() {
        lyricsItems = []
        updateHeightConstraintsForTextViews()
        idxOfSubtitleItemShowing = nil
        subtitleStackEl.bounds.origin = NSPoint(x: 0, y: 0)
        subtitleStackEl.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    // MARK: - API Methods

    public func startShow(_ coverUrls: [String]) {
        self.coverUrls = coverUrls
        updateCoverCycler()
    }
    
    public func updateSubtitles(_ song: SongModel) {
        removeSubtitles()
        
        guard let path = GeneralHelpers.getSongDirPathFromSongKeyname(song.keyname) else { return }
        guard let lyrics = try? String.init(contentsOf: URL(fileURLWithPath: "\(path)/_lyrics.txt")) else { return }
        
        lyrics.components(separatedBy: "\n\n").forEach { el in
            let tv = NSTextView()
            var elComponents = el.components(separatedBy: "\n")
            let timeComponents = elComponents.removeFirst().components(separatedBy: ":")
            let time = Int(timeComponents[0])! * 60 + Int(timeComponents[1])!

            tv.isEditable = false
            tv.isSelectable =  false
            tv.alignment = .center
            tv.backgroundColor = .clear
            tv.textColor = .darkGray
            tv.font = NSFont.systemFont(ofSize: 28)
            let heightAnchor = tv.heightAnchorToEqualGet(height: 1)
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
        
        updateHeightConstraintsForTextViews()
    }
    
    public func syncSubtitles(withCurrentTime time: Double) {
        let time = Int(time)
        let lastIndex = lyricsItems.count - 1
        var idxToShow: Int = 0
        
        let lyricsItem = lyricsItems.enumerated().first { (i, el) -> Bool in
            if (i < lastIndex && lyricsItems[i + 1].time >= time) || i == lastIndex {
                idxToShow = i
                return true
            }
            return false
        }

        if idxToShow == idxOfSubtitleItemShowing { return }
        guard let newLyricsItem = lyricsItem?.element else { return }
        
        idxOfSubtitleItemShowing = idxToShow
        updateHeightConstraintsForTextViews()
        
        lyricsItems.forEach { (view, _, _) in view.textColor = .darkGray }
        newLyricsItem.view.textColor = .white
        
        let itemHeight = newLyricsItem.view.frame.height
        let newYPos = (newLyricsItem.view.frame.origin.y + itemHeight) - subtitleStackEl.frame.height + (subtitleStackContainerEl.frame.height / 2) - (itemHeight / 2)
        
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current().duration = 0.4
        NSAnimationContext.current().timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        subtitleStackEl.animator().setBoundsOrigin(NSPoint(x: 0, y: newYPos))
        NSAnimationContext.endGrouping()
    }
}

//
//  Player.swift
//  music-player-mac
//
//  Created by Erwin GO on 4/28/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa
import MediaPlayer
import AVFoundation

class Player: View {
    // MARK: - Properties

    private let coverEl = PlayerCover()

    private lazy var playerCoreEl: PlayerCore = {
        let v = PlayerCore(onSongStartedPlaying: self.handleSongStartedPlaying, onSongPaused: self.handleSongPaused)
        return v
    }()
    
    // MARK: - Inits

    override init() {
        super.init()
        layer?.backgroundColor = NSColor.red.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayPauseMediaKey), name: .customPlayPauseMediaKeyPressed, object: nil)
        
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initViews() {
        addSubview(coverEl)
        coverEl.widthAnchorToLessThanOrEqual(anchor: widthAnchor, constant: -20, options: ["priority": 20])
        coverEl.widthAnchorToEqual(anchor: coverEl.heightAnchor, options: ["priority": 10])
        coverEl.heightAnchorToEqual(anchor: heightAnchor, constant: -20, multiplier: 0.5)
        coverEl.topAnchorToEqual(topAnchor, constant: 10)
        coverEl.centerXAnchorToEqual(centerXAnchor)
        
        let playBtnEl = NSButton()
        playBtnEl.wantsLayer = true
        playBtnEl.layer?.backgroundColor = CGColor.clear
        playBtnEl.alternateImage = #imageLiteral(resourceName: "icon - play")
        playBtnEl.setButtonType(NSButtonType.momentaryChange)
        playBtnEl.isBordered = false
        playBtnEl.imageScaling = .scaleProportionallyDown
        playBtnEl.image = #imageLiteral(resourceName: "icon - play")
        addSubview(playBtnEl)
        playBtnEl.widthAnchorToEqual(width: 80)
        playBtnEl.heightAnchorToEqual(height: 80)
        playBtnEl.topAnchorToEqual(coverEl.bottomAnchor)
        playBtnEl.leftAnchorToEqual(coverEl.leftAnchor)
        
        layer?.addSublayer(AVPlayerLayer(player: playerCoreEl))
        playerCoreEl.volume = 0.05
        _ = self.playerCoreEl.updateSong(id: "759")
//        self.playerCoreEl.playSong()
    }
    
    // MARK: - Private Methods

    @objc private func handlePlayPauseMediaKey() {
        if playerCoreEl.isPlaying {
            playerCoreEl.pauseSong()
        } else {
            playerCoreEl.playSong()
        }
    }
    
    private func handleSongStartedPlaying() {
        Swift.print("Song started playing")
    }
    
    private func handleSongPaused() {
        Swift.print("Song paused")
    }
}

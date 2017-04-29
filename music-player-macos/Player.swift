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
        let v = PlayerCore()
        return v
    }()
    
    // MARK: - Inits

    override init() {
        super.init()
        layer?.backgroundColor = NSColor.red.cgColor
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        addSubview(coverEl)
        coverEl.widthAnchorToLessThanOrEqual(anchor: widthAnchor, constant: -20, options: ["priority": 20])
        coverEl.widthAnchorToEqual(anchor: coverEl.heightAnchor, options: ["priority": 10])
        coverEl.heightAnchorToEqual(anchor: heightAnchor, constant: -20, multiplier: 0.5)
        coverEl.topAnchorToEqual(topAnchor, constant: 10)
        coverEl.centerXAnchorToEqual(centerXAnchor)
        
        let playBtnEl = NSButton()
        playBtnEl.title = "Play"
        addSubview(playBtnEl)
        playBtnEl.topAnchorToEqual(coverEl.bottomAnchor)
        playBtnEl.leftAnchorToEqual(coverEl.leftAnchor)
        
        NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.keyDown) { event in
            Swift.print("LUUUUUUUUUUUUUUUUUUUUUL")
        }
        
//        UIApplication.shared.beginReceivingRemoteControlEvents()
        
//        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//        try! AVAudioSession.sharedInstance().setActive(true)
//        
//        let remoteCommandCenter = MPRemoteCommandCenter.shared()
//        remoteCommandCenter.pauseCommand.addTarget(handler: handleRemotePauseCommand)
//        remoteCommandCenter.playCommand.addTarget(handler: handleRemotePlayCommand)

        
        layer?.addSublayer(AVPlayerLayer(player: playerCoreEl))
        playerCoreEl.volume = 0.02
        _ = self.playerCoreEl.updateSong(id: "759")
        self.playerCoreEl.playSong()
    }
}

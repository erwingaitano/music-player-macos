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

    private lazy var playerCoreEl: PlayerCore = {
        let v = PlayerCore(onSongStartedPlaying: self.handleSongStartedPlaying, onSongPaused: self.handleSongPaused)
        return v
    }()
    
    private var playPauseBtnEl: Button = {
        let v = Button()
        v.widthAnchorToEqual(width: 80)
        v.heightAnchorToEqual(height: 80)
        v.image = #imageLiteral(resourceName: "icon - play")
        return v
    }()
    
    private var fastBackwardBtnEl: Button = {
        let v = Button()
        v.widthAnchorToEqual(width: 37)
        v.heightAnchorToEqual(height: 30)
        v.image = #imageLiteral(resourceName: "icon - fastbackward")
        return v
    }()
    
    private var fastForwardBtnEl: Button = {
        let v = Button()
        v.widthAnchorToEqual(width: 37)
        v.heightAnchorToEqual(height: 30)
        v.image = #imageLiteral(resourceName: "icon - fastforward")
        return v
    }()
    
    private lazy var mediaControlsEl: View = {
        let v = View()
        
        v.addSubview(self.playPauseBtnEl)
        self.playPauseBtnEl.centerXAnchorToEqual(v.centerXAnchor)
        self.playPauseBtnEl.centerYAnchorToEqual(v.centerYAnchor)
        
        v.addSubview(self.fastBackwardBtnEl)
        self.fastBackwardBtnEl.centerYAnchorToEqual(self.playPauseBtnEl.centerYAnchor)
        self.fastBackwardBtnEl.leftAnchorToEqual(v.leftAnchor)
        
        v.addSubview(self.fastForwardBtnEl)
        self.fastForwardBtnEl.centerYAnchorToEqual(self.playPauseBtnEl.centerYAnchor)
        self.fastForwardBtnEl.rightAnchorToEqual(v.rightAnchor)
        
        return v
    }()
    
    private var infoSectionImgEl: PlayerCover = {
        let v = PlayerCover()
        v.layer?.backgroundColor = NSColor.hexStringToColor(hex: "#D8D8D8").cgColor
        return v
    }()
    
    private var infoSectionTitleEl: Label = {
        let v = Label()
        v.stringValue = "This is the name of the Song"
        v.font = NSFont.systemFont(ofSize: 18)
        v.textColor = .white
        return v
    }()
    
    private var infoSectionSubtitleEl: Label = {
        let v = Label()
        v.stringValue = "This is the album/artist"
        v.font = NSFont.systemFont(ofSize: 14)
        v.textColor = .secondaryColor
        return v
    }()
    
    private var infoSectionTimeStartEl: Label = {
        let v = Label()
        v.stringValue = "-:--"
        v.font = NSFont.systemFont(ofSize: 13)
        v.textColor = .white
        v.alignment = .left
        return v
    }()
    
    private var infoSectionTimeEndEl: Label = {
        let v = Label()
        v.stringValue = "-:--"
        v.font = NSFont.systemFont(ofSize: 13)
        v.textColor = .white
        v.alignment = .right
        return v
    }()
    
    private var infoSectionSliderEl: NSSlider = {
        let v = NSSlider()
        v.wantsLayer = true
        v.maxValue = 200
        v.floatValue = 50
        v.layer?.backgroundColor = NSColor.hexStringToColor(hex: "#333333").cgColor
        return v
    }()
    
    private lazy var containerInfoSectionEl: View = {
        let v = View()
        v.layer?.backgroundColor = NSColor.hexStringToColor(hex: "#222222").cgColor
        
        v.addSubview(self.infoSectionImgEl)
        self.infoSectionImgEl.widthAnchorToEqual(anchor: self.infoSectionImgEl.heightAnchor)
        self.infoSectionImgEl.topAnchorToEqual(v.topAnchor, constant: 5)
        self.infoSectionImgEl.bottomAnchorToEqual(v.bottomAnchor, constant: -5)
        self.infoSectionImgEl.leftAnchorToEqual(v.leftAnchor, constant: 5)
        
        v.addSubview(self.infoSectionTitleEl)
        self.infoSectionTitleEl.heightAnchorToEqual(height: 24)
        self.infoSectionTitleEl.topAnchorToEqual(self.infoSectionImgEl.topAnchor, constant: 4)
        self.infoSectionTitleEl.leftAnchorToEqual(self.infoSectionImgEl.rightAnchor, constant: 10)
        
        v.addSubview(self.infoSectionSubtitleEl)
        self.infoSectionSubtitleEl.heightAnchorToEqual(height: 20)
        self.infoSectionSubtitleEl.topAnchorToEqual(self.infoSectionTitleEl.bottomAnchor, constant: 0)
        self.infoSectionSubtitleEl.leftAnchorToEqual(self.infoSectionImgEl.rightAnchor, constant: 10)
        
        v.addSubview(self.infoSectionTimeStartEl)
        self.infoSectionTimeStartEl.heightAnchorToEqual(height: 18)
        self.infoSectionTimeStartEl.bottomAnchorToEqual(self.infoSectionImgEl.bottomAnchor, constant: -4)
        self.infoSectionTimeStartEl.leftAnchorToEqual(self.infoSectionImgEl.rightAnchor, constant: 10)
        
        v.addSubview(self.infoSectionTimeEndEl)
        self.infoSectionTimeEndEl.heightAnchorToEqual(height: 18)
        self.infoSectionTimeEndEl.bottomAnchorToEqual(self.infoSectionTimeStartEl.bottomAnchor)
        self.infoSectionTimeEndEl.rightAnchorToEqual(v.rightAnchor, constant: -10)
        
        v.addSubview(self.infoSectionSliderEl)
        self.infoSectionSliderEl.heightAnchorToEqual(height: 20)
        self.infoSectionSliderEl.centerYAnchorToEqual(self.infoSectionTimeStartEl.centerYAnchor)
        self.infoSectionSliderEl.leftAnchorToEqual(self.infoSectionImgEl.rightAnchor, constant: 50)
        self.infoSectionSliderEl.rightAnchorToEqual(v.rightAnchor, constant: -50)
        
        return v
    }()
    
    private lazy var mainContainerEl: View = {
        let v = View()
        
        v.addSubview(self.containerInfoSectionEl)
        self.containerInfoSectionEl.topAnchorToEqual(v.topAnchor)
        self.containerInfoSectionEl.bottomAnchorToEqual(v.bottomAnchor)
        self.containerInfoSectionEl.widthAnchorToEqual(width: 405)
        self.containerInfoSectionEl.rightAnchorToEqual(v.rightAnchor)
        
        v.addSubview(self.mediaControlsEl)
        self.mediaControlsEl.topAnchorToEqual(v.topAnchor)
        self.mediaControlsEl.bottomAnchorToEqual(v.bottomAnchor)
        self.mediaControlsEl.rightAnchorToEqual(self.containerInfoSectionEl.leftAnchor, constant: -20)
        self.mediaControlsEl.widthAnchorToEqual(width: 200)

        v.leftAnchorToEqual(self.mediaControlsEl.leftAnchor)
        v.rightAnchorToEqual(self.containerInfoSectionEl.rightAnchor)
        
        return v
    }()
    
    // MARK: - Inits

    override init() {
        super.init()
        layer?.backgroundColor = NSColor.black.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayPauseMediaKey), name: .customPlayPauseMediaKeyPressed, object: nil)
        layer?.addSublayer(AVPlayerLayer(player: playerCoreEl))
        
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initViews() {
        addSubview(mainContainerEl)
        mainContainerEl.centerXAnchorToEqual(centerXAnchor)
        mainContainerEl.topAnchorToEqual(topAnchor)
        mainContainerEl.bottomAnchorToEqual(bottomAnchor)
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
        setPlayPauseBtnElStatus()
    }
    
    private func handleSongPaused() {
        setPlayPauseBtnElStatus(false)
    }
    
    private func setPlayPauseBtnElStatus(_ isPlaying: Bool = true) {
        if isPlaying { playPauseBtnEl.image = #imageLiteral(resourceName: "icon - pause") }
        else { playPauseBtnEl.image = #imageLiteral(resourceName: "icon - play") }
    }
    
    // MARK: - API Methods

    private var updateSongPromiseEl: ApiEndpointsHelpers.PromiseEl?
    public func updateSong(_ song: SongModel) {
        updateSongPromiseEl?.canceler()
        self.infoSectionImgEl.setCovers(song.allCovers)
        self.infoSectionTitleEl.stringValue = song.name
        self.infoSectionSubtitleEl.stringValue = GeneralHelpers.getAlbumArtist(album: song.album, artist: song.artist)
        
        updateSongPromiseEl = playerCoreEl.updateSong(id: song.id)
        _ = updateSongPromiseEl?.promise.then(execute: { _ -> Void in
        })
    }
    
    public func play() {
        playerCoreEl.playSong()
        setPlayPauseBtnElStatus()
    }
    
    public func pause() {
        playerCoreEl.pauseSong()
        setPlayPauseBtnElStatus(false)
    }
}

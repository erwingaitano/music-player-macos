//
//  Player.swift
//  music-player-mac
//
//  Created by Erwin GO on 4/28/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

class Player: View {
    // MARK: - Typealiases

    typealias OnSliderChange = (_ value: Double) -> Void
    typealias OnPlayPauseBtnClick = () -> Void
    
    // MARK: - Properties
    
    private var onSliderChange: OnSliderChange?
    private var onPlayPauseBtnClick: OnPlayPauseBtnClick?
    
    private lazy var playPauseBtnEl: Button = {
        let v = Button()
        v.target = self
        v.action = #selector(self.handlePlayPauseBtnElClick)
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
        v.stringValue = "-"
        v.font = NSFont.systemFont(ofSize: 18)
        v.textColor = .white
        return v
    }()
    
    private var infoSectionSubtitleEl: Label = {
        let v = Label()
        v.stringValue = "-"
        v.font = NSFont.systemFont(ofSize: 14)
        v.textColor = .secondaryColor
        return v
    }()
    
    private var infoSectionTimeStartEl: Label = {
        let v = Label()
        v.font = NSFont.systemFont(ofSize: 13)
        v.textColor = .white
        v.alignment = .left
        return v
    }()
    
    private var infoSectionTimeEndEl: Label = {
        let v = Label()
        v.font = NSFont.systemFont(ofSize: 13)
        v.textColor = .white
        v.alignment = .right
        return v
    }()
    
    private lazy var infoSectionSliderEl: NSSlider = {
        let v = NSSlider()
        v.wantsLayer = true
        v.target = self
        v.action = #selector(self.handleSliderChange)
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
        self.infoSectionSliderEl.leftAnchorToEqual(self.infoSectionImgEl.rightAnchor, constant: 55)
        self.infoSectionSliderEl.rightAnchorToEqual(v.rightAnchor, constant: -55)
        
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

    init(onPlayPauseBtnClick: OnPlayPauseBtnClick?, onSliderChange: OnSliderChange?) {
        super.init()
        self.onPlayPauseBtnClick = onPlayPauseBtnClick
        self.onSliderChange = onSliderChange
        layer?.backgroundColor = NSColor.black.cgColor
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        addSubview(mainContainerEl)
        mainContainerEl.centerXAnchorToEqual(centerXAnchor)
        mainContainerEl.topAnchorToEqual(topAnchor)
        mainContainerEl.bottomAnchorToEqual(bottomAnchor)
    }
    
    // MARK: - Private Methods
    
    @objc private func handleSliderChange() {
         onSliderChange?(infoSectionSliderEl.doubleValue)
    }
    
    @objc private func handlePlayPauseBtnElClick() {
         onPlayPauseBtnClick?()
    }
    
    // MARK: - API Methods
    
    public func setPlayPauseBtnElStatus(_ isPlaying: Bool = true) {
        if isPlaying { playPauseBtnEl.image = #imageLiteral(resourceName: "icon - pause") }
        else { playPauseBtnEl.image = #imageLiteral(resourceName: "icon - play") }
    }
    
    public func updateTimeLabels(currentTime: Double?, duration: Double?) {
        guard let currentTime = currentTime, let duration = duration, !duration.isNaN else {
            infoSectionTimeStartEl.stringValue = "-:--"
            infoSectionTimeEndEl.stringValue = "-:--"
            return
        }
        
        infoSectionTimeEndEl.stringValue = Int(duration).getMinuteSecondFormattedString()
        infoSectionTimeStartEl.stringValue = Int(currentTime).getMinuteSecondFormattedString()
    }
    
    public func updateSlider(currentTime: Double?, duration: Double?) {
        guard let currentTime = currentTime, let duration = duration else {
            infoSectionSliderEl.isEnabled = false
            infoSectionSliderEl.maxValue = 0
            infoSectionSliderEl.doubleValue = 0
            return
        }
        
        if !duration.isNaN {
            infoSectionSliderEl.maxValue = duration
            infoSectionSliderEl.doubleValue = currentTime
            infoSectionSliderEl.isEnabled = true
        }
    }
    
    public func updateSongInfo(song: SongModel, currentTime: Double?, duration: Double?) {
        infoSectionImgEl.setCovers(song.allCovers)
        infoSectionTitleEl.stringValue = song.name
        infoSectionSubtitleEl.stringValue = GeneralHelpers.getAlbumArtist(album: song.album, artist: song.artist)
        updateTimeLabels(currentTime: currentTime, duration: duration)
        updateSlider(currentTime: currentTime, duration: currentTime)
    }
    
    public func emptySongInfo() {
        infoSectionImgEl.setCovers([])
        infoSectionTitleEl.stringValue = "-"
        infoSectionSubtitleEl.stringValue = "-"
        updateTimeLabels(currentTime: nil, duration: nil)
        updateSlider(currentTime: nil, duration: nil)
    }
}

//
//  MainController.swift
//  music-player-mac
//
//  Created by Erwin GO on 4/28/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa
import AVFoundation

class MainController: NSViewController {
    // MARK: - Properties

    private var listViewEl: ListView!
    private var playingListViewEl: ListView!
    private var listViewType: String!
    private var playerEl: Player!
    private var shouldRepeatPlaylist = false
    private var songsUpdatedObserver: NSObjectProtocol!
    private var updateSongPromiseEl: ApiEndpointsHelpers.PromiseEl?
    private var onSongFinished: PlayerCore.EmptyCallback?
    
    private lazy var playerCoreEl: PlayerCore = {
        let v = PlayerCore(onProgress: self.handleProgress, onSongStartedPlaying: self.handleSongStartedPlaying, onSongPaused: self.handleSongPaused, onSongFinished: self.handleSongFinished)
        return v
    }()
    
    private lazy var sidebarEl: View = {
        let v = View()
        v.layer?.backgroundColor = NSColor.blue.cgColor
        
        let allSongsBtnEl = NSButton()
        allSongsBtnEl.title = "All Songs"
        allSongsBtnEl.target = self
        allSongsBtnEl.action = #selector(self.showAllSongs)
        v.addSubview(allSongsBtnEl)
        allSongsBtnEl.topAnchorToEqual(v.topAnchor)
        allSongsBtnEl.leftAnchorToEqual(v.leftAnchor)

        let allPlaylistsBtnEl = NSButton()
        allPlaylistsBtnEl.title = "All Playlists"
        allPlaylistsBtnEl.target = self
        allPlaylistsBtnEl.action = #selector(self.showAllPlaylists)
        v.addSubview(allPlaylistsBtnEl)
        allPlaylistsBtnEl.topAnchorToEqual(allSongsBtnEl.bottomAnchor)
        allPlaylistsBtnEl.leftAnchorToEqual(v.leftAnchor)
        
        let playAllSongsBtnEl = NSButton()
        playAllSongsBtnEl.title = "Play all songs"
        playAllSongsBtnEl.target = self
        playAllSongsBtnEl.action = #selector(self.playAllSongs)
        v.addSubview(playAllSongsBtnEl)
        playAllSongsBtnEl.topAnchorToEqual(allPlaylistsBtnEl.bottomAnchor)
        playAllSongsBtnEl.leftAnchorToEqual(v.leftAnchor)
    
        return v
    }()
    
    // MARK: - Inits

    init() {
        super.init(nibName: nil, bundle: nil)!
        view.layer?.backgroundColor = NSColor.black.cgColor
        songsUpdatedObserver = NotificationCenter.default.addObserver(forName: .customSongsUpdated, object: nil, queue: nil, using: handleSongsUpdated)
        NotificationCenter.default.addObserver(self, selector: #selector(togglePlayPause), name: .customPlayPauseMediaKeyPressed, object: nil)
        view.layer?.addSublayer(AVPlayerLayer(player: playerCoreEl))
        initViews()
        
        updateSongs()
        showAllSongs()
        AppSingleton.shared.updateSongs()
        AppSingleton.shared.updatePlaylists()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(songsUpdatedObserver)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initViews() {
        let title = NSTextField()
        title.isEditable = false
        title.stringValue = "Does this work"
        title.isBordered = false
        title.font = NSFont.systemFont(ofSize: 18)
        title.textColor = .blue
        
        playerEl = Player(onPlayPauseBtnClick: togglePlayPause, onSliderChange: handleSliderChange)
        view.addSubview(playerEl)
        playerEl.heightAnchorToEqual(height: 100)
        playerEl.topAnchorToEqual(view.topAnchor)
        playerEl.leftAnchorToEqual(view.leftAnchor)
        playerEl.rightAnchorToEqual(view.rightAnchor)
        
        view.addSubview(sidebarEl)
        sidebarEl.topAnchorToEqual(playerEl.bottomAnchor)
        sidebarEl.bottomAnchorToEqual(view.bottomAnchor)
        sidebarEl.leftAnchorToEqual(view.leftAnchor)
        sidebarEl.widthAnchorToEqual(width: 200)
        
        playingListViewEl = ListView("Playing", onItemSelected: handlePlayingListItemSelected)
        view.addSubview(playingListViewEl)
        playingListViewEl.topAnchorToEqual(playerEl.bottomAnchor)
        playingListViewEl.bottomAnchorToEqual(view.bottomAnchor)
        playingListViewEl.widthAnchorToEqual(width: 300)
        playingListViewEl.rightAnchorToEqual(view.rightAnchor)
        
        listViewEl = ListView("...", onItemSelected: handleListItemSelected)
        view.addSubview(listViewEl)
        listViewEl.topAnchorToEqual(playerEl.bottomAnchor)
        listViewEl.bottomAnchorToEqual(view.bottomAnchor)
        listViewEl.leftAnchorToEqual(sidebarEl.rightAnchor)
        listViewEl.rightAnchorToEqual(playingListViewEl.leftAnchor)
        
        let playerElSeparatorEl = View()
        view.addSubview(playerElSeparatorEl)
        playerElSeparatorEl.layer?.backgroundColor = NSColor.white.cgColor
        playerElSeparatorEl.heightAnchorToEqual(height: 1)
        playerElSeparatorEl.topAnchorToEqual(playerEl.bottomAnchor)
        playerElSeparatorEl.leftAnchorToEqual(playerEl.leftAnchor)
        playerElSeparatorEl.rightAnchorToEqual(playerEl.rightAnchor)
        
        let playingListElSeparatorEl = View()
        view.addSubview(playingListElSeparatorEl)
        playingListElSeparatorEl.layer?.backgroundColor = NSColor.white.cgColor
        playingListElSeparatorEl.widthAnchorToEqual(width: 1)
        playingListElSeparatorEl.topAnchorToEqual(playingListViewEl.topAnchor)
        playingListElSeparatorEl.bottomAnchorToEqual(playingListViewEl.bottomAnchor)
        playingListElSeparatorEl.leftAnchorToEqual(playingListViewEl.leftAnchor)
    }
    
    // MARK: - Life Cycles
    
    override func loadView() {
        self.view = View()
    }
    
    // MARK: - Private Methods
    
    @objc private func togglePlayPause() {
        if playerCoreEl.isPlaying { playerCoreEl.pause() }
        else { playerCoreEl.play() }
    }
    
    private func playPlaylist(_ songs: [SongModel]) {
        playingListViewEl.updateData(ListView.getMediaCellDataArrayFromSongModelArray(songs))
        AppSingleton.shared.updateSongsPlaying(songs)
        playPlaylistSongAtIndex(0)
    }
    
    private func playPlaylistSongAtIndex(_ idx: Int, shouldStartPlaying: Bool = true) {
        let songsPlayingCount = AppSingleton.shared.songsPlaying.count
        
        guard songsPlayingCount > 0 else { return }
        
        if idx < songsPlayingCount {
            AppSingleton.shared.updateCurrentSongIdx(idx)
            updatePlayerSong(AppSingleton.shared.songsPlaying[AppSingleton.shared.currentSongIdx])
            if shouldStartPlaying { playerCoreEl.play() }
            else { playerCoreEl.pause() }
        } else {
            AppSingleton.shared.updateCurrentSongIdx(0)
            updatePlayerSong(AppSingleton.shared.songsPlaying[0])
            
            if shouldRepeatPlaylist { playerCoreEl.play() }
            else { playerCoreEl.pause() }
        }
    }
    
    @objc private func playAllSongs() {
        playPlaylist(AppSingleton.shared.songs)
    }
    
    @objc private func showAllPlaylists() {
        listViewEl.updateData(ListView.getMediaCellDataArrayFromPlaylistModelArray(AppSingleton.shared.playlists))
        listViewEl.updateTitle("All Playlists")
        listViewType = "playlists"
    }
    
    @objc private func showAllSongs() {
        listViewEl.updateData(ListView.getMediaCellDataArrayFromSongModelArray(AppSingleton.shared.songs))
        listViewEl.updateTitle("All Songs")
        listViewType = "songs"
    }
    
    private func updateSongs() {
        listViewEl.updateData(ListView.getMediaCellDataArrayFromSongModelArray(AppSingleton.shared.songs))
    }
    
    private func updatePlayerSong(_ song: SongModel) {
        updateSongPromiseEl?.canceler()
        playerEl.updateSongInfo(song: song, currentTime: nil, duration: nil)
        
        updateSongPromiseEl = playerCoreEl.updateSong(id: song.id)
        _ = updateSongPromiseEl?.promise.then(execute: { _ -> Void in
            let duration = CMTimeGetSeconds(self.playerCoreEl.currentItem!.duration)
            self.playerEl.updateSongInfo(song: song, currentTime: 0, duration: duration)
        })
    }
    
    private func handleSliderChange(value: Double) {
        playerCoreEl.setTime(time: value)
    }

    private func handleProgress(currentTime: Double, duration: Double) {
        playerEl.updateTimeLabels(currentTime: currentTime, duration: duration)
        playerEl.updateSlider(currentTime: currentTime, duration: duration)
    }
    
    private func handleSongStartedPlaying() {
        playerEl.setPlayPauseBtnElStatus()
    }
    
    private func handleSongPaused() {
        playerEl.setPlayPauseBtnElStatus(false)
    }
    
    private func handleSongFinished() {
        playerEl.setPlayPauseBtnElStatus(false)
        playPlaylistSongAtIndex(AppSingleton.shared.currentSongIdx + 1)
    }

    private func handleListItemSelected(item: MediaCell.Data) {
        if listViewType == "songs" {
            let song = AppSingleton.shared.songs.first(where: { $0.id == item.id })!
            playPlaylist([song])
        }
    }
    
    private func handlePlayingListItemSelected(item: MediaCell.Data) {
        let idx = AppSingleton.shared.songsPlaying.index(where: { $0.id == item.id })!
        playPlaylistSongAtIndex(idx)
    }
    
    private func handleSongsUpdated(_: Notification) {
        updateSongs()
    }
}

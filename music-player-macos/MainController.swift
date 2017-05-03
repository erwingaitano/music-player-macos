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
    private var playerEl: Player!
    private var shouldRepeatPlayingSongs = false
    private var songsUpdatedObserver: NSObjectProtocol!
    private var songsPlayingUpdatedObserver: NSObjectProtocol!
    private var playlistsUpdatedObserver: NSObjectProtocol!
    private var updateSongPromiseEl: ApiEndpointsHelpers.PromiseEl?
    private var getPlaylistSongsPromiseEl: ApiEndpointsHelpers.SongsPromiseEl?
    
    private lazy var playerCoreEl: PlayerCore = {
        let v = PlayerCore(onProgress: self.handleProgress, onSongStartedPlaying: self.handleSongStartedPlaying, onSongPaused: self.handleSongPaused, onSongFinished: self.handleSongFinished)
        return v
    }()
    
    private var libraryData = [(id: "allsongs", name: "All Songs")]
    
    private lazy var sidebarEl: Sidebar = {
        let v = Sidebar(items: [.library: self.libraryData, .playlists: []], onItemClick: self.handleSidebarItemClick)
        return v
    }()
    
    // MARK: - Inits

    init() {
        super.init(nibName: nil, bundle: nil)!
        view.layer?.backgroundColor = NSColor.black.cgColor
        view.layer?.addSublayer(AVPlayerLayer(player: playerCoreEl))
        
        songsUpdatedObserver = NotificationCenter.default.addObserver(forName: .customSongsUpdated, object: nil, queue: nil, using: handleSongsUpdated)
        playlistsUpdatedObserver = NotificationCenter.default.addObserver(forName: .customPlaylistsUpdated, object: nil, queue: nil, using: handlePlaylistsUpdated)
        songsPlayingUpdatedObserver = NotificationCenter.default.addObserver(forName: .customSongsPlayingUpdated, object: nil, queue: nil, using: handleSongsPlayingUpdated)
        NotificationCenter.default.addObserver(self, selector: #selector(togglePlayPause), name: .customPlayPauseMediaKeyPressed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFastForwardClick), name: .customFastForwardMediaKeyPressed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goPreviousSong), name: .customFastBackwardMediaKeyPressed, object: nil)
        
        initViews()
        
        showAllSongs()
        AppSingleton.shared.updateSongs()
        AppSingleton.shared.updatePlaylists()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(songsUpdatedObserver)
        NotificationCenter.default.removeObserver(playlistsUpdatedObserver)
        NotificationCenter.default.removeObserver(songsPlayingUpdatedObserver)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initViews() {
        let title = NSTextField()
        title.isEditable = false
        title.stringValue = "Does this work"
        title.isBordered = false
        title.font = NSFont.systemFont(ofSize: 18)
        title.textColor = .blue
        
        playerEl = Player(onPlayPauseBtnClick: togglePlayPause, onFastBackwardClick: goPreviousSong, onFastForwardClick: handleFastForwardClick, onSliderChange: handleSliderChange)
        playerEl.onVolumeSliderChange = handleVolumeSliderChange
        playerEl.updateVolumeSlider(Double(playerCoreEl.volume))
        playerEl.onRepeatBtnClick = handleRepeatBtnClick
        playerEl.onShuffleBtnClick = handleShuffleBtnClick
        
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
        
        let sidebarElSeparatorEl = getSeparator(width: 1)
        view.addSubview(sidebarElSeparatorEl)
        sidebarElSeparatorEl.topAnchorToEqual(playerEl.bottomAnchor)
        sidebarElSeparatorEl.bottomAnchorToEqual(view.bottomAnchor)
        sidebarElSeparatorEl.leftAnchorToEqual(sidebarEl.rightAnchor)
        
        let playerElSeparatorEl = getSeparator(height: 1)
        view.addSubview(playerElSeparatorEl)
        playerElSeparatorEl.topAnchorToEqual(playerEl.bottomAnchor)
        playerElSeparatorEl.leftAnchorToEqual(playerEl.leftAnchor)
        playerElSeparatorEl.rightAnchorToEqual(playerEl.rightAnchor)
        
        let playingListElSeparatorEl = getSeparator(width: 1)
        view.addSubview(playingListElSeparatorEl)
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
    
    @objc private func goPreviousSong() {
        playPlaylistSongAtIndex(AppSingleton.shared.currentSongIdx - 1, shouldStartPlaying: playerCoreEl.isPlaying)
    }
    
    private func goNextSong() {
        playPlaylistSongAtIndex(AppSingleton.shared.currentSongIdx + 1, shouldStartPlaying: playerCoreEl.isPlaying)
    }
    
    private func playPlaylist(_ songs: [SongModel]) {
        AppSingleton.shared.updateSongsPlaying(songs)
        
        if songs.count == 0 {
            playerCoreEl.stop()
            playerEl.emptySongInfo()
        } else {
            playPlaylistSongAtIndex(0, shouldStartPlaying: true)
        }
    }
    
    private func playPlaylistSongAtIndex(_ idx: Int, shouldStartPlaying: Bool, shouldStartPlayingSongAfterReachingEnd: Bool? = nil) {
        let songsPlayingCount = AppSingleton.shared.songsPlaying.count
        guard songsPlayingCount > 0 && idx >= 0 else { return }
        
        if idx < songsPlayingCount {
            AppSingleton.shared.updateCurrentSongIdx(idx)
            updatePlayerSong(AppSingleton.shared.songsPlaying[AppSingleton.shared.currentSongIdx])
            if shouldStartPlaying { playerCoreEl.play() }
            else { playerCoreEl.pause() }
        } else {
            AppSingleton.shared.updateCurrentSongIdx(0)
            updatePlayerSong(AppSingleton.shared.songsPlaying[0])
            
            var shouldRepeatPlayingSongs = self.shouldRepeatPlayingSongs
            if shouldStartPlayingSongAfterReachingEnd != nil { shouldRepeatPlayingSongs = shouldStartPlayingSongAfterReachingEnd! }
            if shouldRepeatPlayingSongs { playerCoreEl.play() }
            else { playerCoreEl.pause() }
        }
    }
    
    @objc private func showAllSongs() {
        listViewEl.updateData(ListView.getMediaCellDataArrayFromSongModelArray(AppSingleton.shared.songs))
        listViewEl.updateTitle("All Songs")
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
    
    private func getSeparator(width: CGFloat? = nil, height: CGFloat? = nil) -> View {
        let v = View()
        v.layer?.backgroundColor = NSColor.hexStringToColor(hex: "#2f2f2f").cgColor
        
        if let width = width { v.widthAnchorToEqual(width: width) }
        if let height = height { v.heightAnchorToEqual(height: height) }
        return v
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
        playPlaylistSongAtIndex(AppSingleton.shared.currentSongIdx + 1, shouldStartPlaying: true)
    }

    private func handleListItemSelected(item: MediaCell.Data) {
        let song = AppSingleton.shared.songs.first(where: { $0.id == item.id })!
        playPlaylist([song])
    }
    
    private func handlePlayingListItemSelected(item: MediaCell.Data) {
        let idx = AppSingleton.shared.songsPlaying.index(where: { $0.id == item.id })!
        playPlaylistSongAtIndex(idx, shouldStartPlaying: true)
    }
    
    private func handleSongsUpdated(_: Notification) {
        showAllSongs()
    }
    
    private func handlePlaylistsUpdated(_: Notification) {
        sidebarEl.updatePlaylists(AppSingleton.shared.playlists)
    }
    
    private func handleSongsPlayingUpdated(_: Notification) {
        playingListViewEl.updateData(ListView.getMediaCellDataArrayFromSongModelArray(AppSingleton.shared.songsPlaying))
    }
    
    @objc private func handleFastForwardClick() {
        playPlaylistSongAtIndex(AppSingleton.shared.currentSongIdx + 1, shouldStartPlaying: playerCoreEl.isPlaying, shouldStartPlayingSongAfterReachingEnd: true)
    }
    
    private func handleSidebarItemClick(type: Sidebar.Kind, id: String) {
        switch type {
        case .library:
            if id == "allsongs" {
                showAllSongs()
                playPlaylist(AppSingleton.shared.songs)
            }
        case .playlists:
            getPlaylistSongsPromiseEl?.canceler()
            playPlaylist([])
            listViewEl.updateData(ListView.getMediaCellDataArrayFromSongModelArray([]))
            listViewEl.updateTitle("Playlist Songs")
            getPlaylistSongsPromiseEl = ApiEndpointsHelpers.getPlaylistSongs(id)
            _ = getPlaylistSongsPromiseEl!.promise.then(execute: { songs -> Void in
                self.listViewEl.updateData(ListView.getMediaCellDataArrayFromSongModelArray(songs))
                self.playPlaylist(songs)
            })
        }
    }
    
    private func handleVolumeSliderChange(value: Double) {
        playerCoreEl.volume = Float(value)
    }
    
    private func handleRepeatBtnClick() {
        shouldRepeatPlayingSongs = !shouldRepeatPlayingSongs
        if shouldRepeatPlayingSongs {
            playerEl.updateRepeatBtnStatus(isActive: true)
        } else {
            playerEl.updateRepeatBtnStatus(isActive: false)
        }
    }
    
    private func handleShuffleBtnClick() {
    
    }
}

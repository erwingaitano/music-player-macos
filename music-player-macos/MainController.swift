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
    private var nonShuffledSongsPlaying: [SongModel] = []
    private var observers: [NSObjectProtocol] = []
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
        
        observers.append(NotificationCenter.default.addObserver(forName: .customSongsUpdated, object: nil, queue: nil, using: handleSongsUpdated))
        observers.append(NotificationCenter.default.addObserver(forName: .customPlaylistsUpdated, object: nil, queue: nil, using: handlePlaylistsUpdated))
        observers.append(NotificationCenter.default.addObserver(forName: .customSongsPlayingUpdated, object: nil, queue: nil, using: handleSongsPlayingUpdated))
        observers.append(NotificationCenter.default.addObserver(forName: .customMenuPlayPauseFired, object: nil, queue: nil, using: handleMenuPlayPauseFired))
        observers.append(NotificationCenter.default.addObserver(forName: .customMenuNextFired, object: nil, queue: nil, using: handleMenuNextFired))
        observers.append(NotificationCenter.default.addObserver(forName: .customMenuPreviousFired, object: nil, queue: nil, using: handleMenuPreviousFired))
        observers.append(NotificationCenter.default.addObserver(forName: .customMenuIncreaseVolumeFired, object: nil, queue: nil, using: handleMenuIncreaseVolumeFired))
        observers.append(NotificationCenter.default.addObserver(forName: .customMenuDecreaseVolumeFired, object: nil, queue: nil, using: handleMenuDecreaseVolumeFired))
        observers.append(NotificationCenter.default.addObserver(forName: .customMenuRepeatFired, object: nil, queue: nil, using: handleMenuRepeatFired))
        observers.append(NotificationCenter.default.addObserver(forName: .customMenuShuffleFired, object: nil, queue: nil, using: handleMenuShuffleFired))
        
        NotificationCenter.default.addObserver(self, selector: #selector(togglePlayPause), name: .customPlayPauseMediaKeyPressed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goNextSongFastForward), name: .customFastForwardMediaKeyPressed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goPreviousSong), name: .customFastBackwardMediaKeyPressed, object: nil)
        
        initViews()
        showAllSongs()
        showAllPlaylists()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initViews() {
        let title = NSTextField()
        title.isEditable = false
        title.stringValue = "Does this work"
        title.isBordered = false
        title.font = NSFont.systemFont(ofSize: 18)
        title.textColor = .blue
        
        playerEl = Player(onPlayPauseBtnClick: togglePlayPause, onFastBackwardClick: goPreviousSong, onFastForwardClick: goNextSongFastForward, onSliderChange: handleSliderChange)
        playerEl.onVolumeSliderChange = handleVolumeSliderChange
        playerEl.updateVolumeSlider(Double(playerCoreEl.volume))
        playerEl.onRepeatBtnClick = handleRepeatBtnClick
        playerEl.onShuffleBtnClick = handleShuffleBtnClick
        playerEl.updateRepeatBtnStatus(isActive: AppSingleton.shared.shouldRepeatPlayingSongs)
        playerEl.updateShuffleBtnStatus(isActive: AppSingleton.shared.shouldShuffleSongs)
        
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
        let idx = AppSingleton.shared.songsPlaying.index(where: { $0.id == AppSingleton.shared.currentSongId })
        guard let songIdxInCurrentPlaylist = idx, songIdxInCurrentPlaylist > 0 else { return }
        
        let newSong = AppSingleton.shared.songsPlaying[songIdxInCurrentPlaylist - 1]
        playPlaylistSong(id: newSong.id, shouldStartPlaying: playerCoreEl.isPlaying)
    }
    
    private func goNextSong(shouldStartPlayingSongAfterReachingEnd: Bool? = nil) {
        let idx = AppSingleton.shared.songsPlaying.index(where: { $0.id == AppSingleton.shared.currentSongId })
        guard var newSongIdxInCurrentPlaylist = idx else { return }
        
        newSongIdxInCurrentPlaylist += 1
        var newSong: SongModel
        var shouldPlaySong = playerCoreEl.isPlaying
        
        if newSongIdxInCurrentPlaylist >= AppSingleton.shared.songsPlaying.count {
            newSongIdxInCurrentPlaylist = 0
            shouldPlaySong = AppSingleton.shared.shouldRepeatPlayingSongs
            if shouldStartPlayingSongAfterReachingEnd != nil { shouldPlaySong = shouldStartPlayingSongAfterReachingEnd! }
        }
        
        newSong = AppSingleton.shared.songsPlaying[newSongIdxInCurrentPlaylist]
        playPlaylistSong(id: newSong.id, shouldStartPlaying: shouldPlaySong)
    }
    
    private func playPlaylist(_ songs: [SongModel]) {
        nonShuffledSongsPlaying = songs
        AppSingleton.shared.updateSongsPlaying(songs)
        
        if AppSingleton.shared.shouldShuffleSongs { shufflePlayingPlaylist() }
        
        if songs.count == 0 {
            playerCoreEl.stop()
            playerEl.emptySongInfo()
        } else {
            playPlaylistSong(id: AppSingleton.shared.songsPlaying[0].id, shouldStartPlaying: true)
        }
    }
    
    private func playPlaylistSong(id: String, shouldStartPlaying: Bool) {
        let idx = AppSingleton.shared.songsPlaying.index(where: { $0.id == id })!
        
        AppSingleton.shared.updateCurrentSong(id)
        updatePlayingSong(AppSingleton.shared.songsPlaying[idx])
        if shouldStartPlaying { playerCoreEl.play() }
        else { playerCoreEl.pause() }
    }
    
    @objc private func showAllSongs() {
        listViewEl.updateData(ListView.getMediaCellDataArrayFromSongModelArray(AppSingleton.shared.songs))
        listViewEl.updateTitle("All Songs")
    }
    
    private func showAllPlaylists() {
        sidebarEl.updatePlaylists(AppSingleton.shared.playlists)
    }
    
    private func updatePlayingSong(_ song: SongModel) {
        updateSongPromiseEl?.canceler()
        playerEl.updateSongInfo(song: song, currentTime: nil, duration: nil)
        playingListViewEl.updateSpecialHighlightedCells(ids: [song.id])
        listViewEl.updateSpecialHighlightedCells(ids: [song.id])
        playingListViewEl.scrollToCell(withId: song.id)
        
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
    
    private func shufflePlayingPlaylist() {
        playerEl.updateShuffleBtnStatus(isActive: true)
        let songsShuffled = AppSingleton.shared.songsPlaying.shuffled()
        AppSingleton.shared.updateSongsPlaying(songsShuffled)
    }
    
    private func toggleRepeat() {
        let shouldRepeatPlayingSongs = !AppSingleton.shared.shouldRepeatPlayingSongs
        AppSingleton.shared.updateShouldRepeatPlayingSongs(shouldRepeatPlayingSongs)
        if shouldRepeatPlayingSongs {
            playerEl.updateRepeatBtnStatus(isActive: true)
        } else {
            playerEl.updateRepeatBtnStatus(isActive: false)
        }
    }
    
    private func toggleShuffle() {
        let isShuffled = !AppSingleton.shared.shouldShuffleSongs
        AppSingleton.shared.updateShouldShuffleSongs(isShuffled)
        
        if isShuffled {
            shufflePlayingPlaylist()
        } else {
            playerEl.updateShuffleBtnStatus(isActive: false)
            AppSingleton.shared.updateSongsPlaying(nonShuffledSongsPlaying)
        }
        
        playingListViewEl.scrollToCell(withId: AppSingleton.shared.currentSongId)
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
        goNextSong()
    }

    private func handleListItemSelected(item: MediaCell.Data) {
        let song = AppSingleton.shared.songs.first(where: { $0.id == item.id })!
        playPlaylist([song])
    }
    
    private func handlePlayingListItemSelected(item: MediaCell.Data) {
        let song = AppSingleton.shared.songsPlaying.first(where: { $0.id == item.id })!
        playPlaylistSong(id: song.id, shouldStartPlaying: true)
    }
    
    private func handleSongsUpdated(_: Notification) {
        showAllSongs()
    }
    
    private func handlePlaylistsUpdated(_: Notification) {
        showAllPlaylists()
    }
    
    private func handleSongsPlayingUpdated(_: Notification) {
        playingListViewEl.updateData(ListView.getMediaCellDataArrayFromSongModelArray(AppSingleton.shared.songsPlaying))
    }
    
    @objc private func goNextSongFastForward() {
        goNextSong()
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
        toggleRepeat()
    }
    
    private func handleShuffleBtnClick() {
        toggleShuffle()
    }
    
    private func handleMenuPlayPauseFired(_: Notification) {
        togglePlayPause()
    }
    
    private func handleMenuNextFired(_: Notification) {
        goNextSongFastForward()
    }
    
    private func handleMenuPreviousFired(_: Notification) {
        goPreviousSong()
    }
    
    private func handleMenuDecreaseVolumeFired(_: Notification) {
        var newVolume = playerCoreEl.volume
        newVolume -= 1 / 20
        
        if newVolume < 0 { newVolume = 0 }
        playerCoreEl.volume = newVolume
        
        playerEl.updateVolumeSlider(Double(newVolume))
    }
    
    private func handleMenuIncreaseVolumeFired(_: Notification) {
        var newVolume = playerCoreEl.volume
        newVolume += 1 / 20
        
        if newVolume > 1 { newVolume = 1 }
        playerCoreEl.volume = newVolume
        
        playerEl.updateVolumeSlider(Double(newVolume))
    }
    
    private func handleMenuRepeatFired(_: Notification) {
        toggleRepeat()
    }
    
    private func handleMenuShuffleFired(_: Notification) {
        toggleShuffle()
    }
}

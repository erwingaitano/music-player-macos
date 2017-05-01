//
//  AppSingleton.swift
//  music-player-mac
//
//  Created by Erwin GO on 4/21/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

class AppSingleton {
    public static let shared = AppSingleton()
    public let apiUrl = "http://localhost:3000/api"
    public private(set) var songs: [SongModel] = []
    public private(set) var songsPlaying: [SongModel] = []
    public private(set) var currentSongIdx: Int = 0
    public private(set) var playlists: [PlaylistModel] = []
    
    public func updateSongs() {
        _ = ApiEndpointsHelpers.getSongs().promise.then(execute: { songs -> Void in
            self.songs = songs
            NotificationCenter.default.post(name: .customSongsUpdated, object: nil)
        })
    }
    
    public func updatePlaylists() {
        _ = ApiEndpointsHelpers.getPlaylists().promise.then(execute: { playlists -> Void in
            self.playlists = playlists
            NotificationCenter.default.post(name: .customPlaylistsUpdated, object: nil)
        })
    }
    
    public func updateSongsPlaying(_ songs: [SongModel]) {
        songsPlaying = songs
        NotificationCenter.default.post(name: .customSongsPlayingUpdated, object: nil)
    }
    
    public func updateCurrentSongIdx(_ idx: Int) {
        currentSongIdx = idx
        NotificationCenter.default.post(name: .customCurrentSongIdxUpdated, object: nil)
    }
}

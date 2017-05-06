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
    public let mediaFolderPath = "/Users/erwin/Music/music-player-files/_media"
    public private(set) var songs: [SongModel] = []
    public private(set) var songsPlaying: [SongModel] = []
    public private(set) var currentSongId: String = ""
    public private(set) var playlists: [PlaylistModel] = []
    public private(set) var shouldRepeatPlayingSongs = UserDefaults.standard.bool(forKey: "shouldRepeatPlayingSongs")
    public private(set) var shouldShuffleSongs = UserDefaults.standard.bool(forKey: "shouldShuffleSongs")
    public private(set) var volume = UserDefaults.standard.float(forKey: "volume")
    
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
    
    public func updateCurrentSong(_ songId: String) {
        currentSongId = songId
        NotificationCenter.default.post(name: .customCurrentSongIdUpdated, object: nil)
    }
    
    public func updateShouldRepeatPlayingSongs(_ val: Bool) {
        UserDefaults.standard.set(val, forKey: "shouldRepeatPlayingSongs")
        shouldRepeatPlayingSongs = val
    }
    
    public func updateShouldShuffleSongs(_ val: Bool) {
        UserDefaults.standard.set(val, forKey: "shouldShuffleSongs")
        shouldShuffleSongs = val
    }
    
    public func updateVolume(_ volume: Float) {
        UserDefaults.standard.set(volume, forKey: "volume")
        self.volume = volume
    }
}

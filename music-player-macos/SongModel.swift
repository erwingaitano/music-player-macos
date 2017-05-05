//
//  SongModel.swift
//  music-player-ios
//
//  Created by Erwin GO on 4/21/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

struct SongModel {
    var id: String
    var name: String
    var keyname: String
    var artist: String?
    var album: String?
    var songCovers: [String]?
    var albumCovers: [String]?
    var artistCovers: [String]?
    var ext: String?
    var allCovers: [String]
    
    init(id: String, name: String, keyname: String, artist: String?, album: String?, songCovers: [String]?, albumCovers: [String]?, artistCovers: [String]?, ext: String?) {
        self.id = id
        self.name = name
        self.keyname = keyname
        self.artist = artist
        self.album = album
        self.songCovers = songCovers
        self.albumCovers = albumCovers
        self.ext = ext
        self.artistCovers = artistCovers
        self.allCovers = GeneralHelpers.mergeArrays(songCovers, albumCovers, artistCovers) as! [String]
    }
}

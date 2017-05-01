//
//  NotificationExtensions.swift
//  music-player-macos
//
//  Created by Erwin GO on 4/28/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let customPlayPauseMediaKeyPressed = Notification.Name("customPlayPauseMediaKeyPressed")
    static let customFastForwardMediaKeyPressed = Notification.Name("customFastForwardMediaKeyPressed")
    static let customFastBackwardMediaKeyPressed = Notification.Name("customFastBackwardMediaKeyPressed")
    static let customSongsUpdated = Notification.Name("customSongsUpdated")
    static let customPlaylistsUpdated = Notification.Name("customPlaylistsUpdated")
    static let customSongsPlayingUpdated = Notification.Name("customSongsPlayingUpdated")
    static let customCurrentSongIdxUpdated = Notification.Name("customCurrentSongIdxUpdated")
}

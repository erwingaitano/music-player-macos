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
    static let customCurrentSongIdUpdated = Notification.Name("customCurrentSongIdUpdated")
    static let customMenuPlayPauseFired = Notification.Name("customMenuPlayPauseFired")
    static let customMenuPreviousFired = Notification.Name("customMenuPreviousFired")
    static let customMenuNextFired = Notification.Name("customMenuNextFired")
    static let customMenuIncreaseVolumeFired = Notification.Name("customMenuIncreaseVolumeFired")
    static let customMenuDecreaseVolumeFired = Notification.Name("customMenuDecreaseVolumeFired")
    static let customMenuRepeatFired = Notification.Name("customMenuRepeatFired")
    static let customMenuShuffleFired = Notification.Name("customMenuShuffleFired")
}

//
//  PlayerCore.swift
//  music-player
//
//  Created by Erwin GO on 4/21/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import AVFoundation
import PromiseKit

class PlayerCore: AVPlayer {
    // MARK: - Typealiases
    
    typealias OnProgress = (_ currentTime: Double, _ duration: Double) -> Void
    private var updateSongPromiseConstructor: Promise<Any>.PendingTuple!
    private(set) var isPlaying = false
    typealias EmptyCallback = () -> Void
    
    // MARK: - Properties
    
    private var onProgress: OnProgress?
    private var progressTimer: Timer?
    private var onSongStartedPlaying: EmptyCallback?
    private var onSongPaused: EmptyCallback?
    private var onSongFinished: EmptyCallback?
    private var songJustStartedObserver: Any!
    
    // MARK: - Inits
    
    init(onProgress: OnProgress? = nil, onSongFinished: EmptyCallback? = nil, onSongStartedPlaying: EmptyCallback? = nil, onSongPaused: EmptyCallback? = nil) {
        super.init()
        self.onProgress = onProgress
        self.onSongStartedPlaying = onSongStartedPlaying
        self.onSongPaused = onSongPaused
        self.onSongFinished = onSongFinished
        volume = 1
        
        //        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 10), queue: DispatchQueue.main, using: handlePeriodicTime)

        addObserver(self, forKeyPath: "rate", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleEndOfSong), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: currentItem)
        
        // NOTE: This observer is not triggered when outside the app, you you need to use
        //       the observer for the status of player.currentItem
        //        songJustStartedObserver = player.addBoundaryTimeObserver(forTimes: [NSValue(time: CMTime(seconds: 1, preferredTimescale: 100))], queue: nil, using: {
        //            self.updateSongPromiseConstructor.fulfill(true)
        //        })
    }
    
    //    required init?(coder aDecoder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    
    deinit {
        //        player.removeTimeObserver(songJustStartedObserver)
    }
    
    // MARK: - Private Methods
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if (rate == 0.0) {
                // Playback stopped
                if (CMTimeGetSeconds(self.currentTime()) >= CMTimeGetSeconds(self.currentItem!.duration)) {
                    // Playback reached end
                } else if (!self.currentItem!.isPlaybackLikelyToKeepUp) {
                    // Not ready to play, wait until enough data is loaded
                } else if (self.error != nil) {
                    // Playback failed
                } else {
                    isPlaying = false
                    onSongPaused?()
                }
            } else {
                isPlaying = true
                onSongStartedPlaying?()
            }
        }
    }
    
    @objc private func handleSongProgress(_: Timer) {
        guard let currentItem = currentItem else { return }
        let duration = CMTimeGetSeconds(currentItem.duration)
        let currentTime = CMTimeGetSeconds(currentItem.currentTime())
        onProgress?(currentTime, duration)
        Swift.print(status == .readyToPlay, duration)
        if status == .readyToPlay {
            updateSongPromiseConstructor.fulfill(true)
        }
    }
    
    private func handlePeriodicTime(_: CMTime) {
        guard let currentItem = currentItem else { return }
        let duration = CMTimeGetSeconds(currentItem.duration)
        let currentTime = CMTimeGetSeconds(currentItem.currentTime())
        onProgress?(currentTime, duration)
    }
    
    @objc private func handleEndOfSong() {
        Swift.print("song finished")
        onSongFinished?()
    }
    
    // MARK: - API Methods
    
    public func setTime(time: Double) {
        guard let currentItem = currentItem else { return }
        currentItem.seek(to: CMTime(seconds: time, preferredTimescale: 1))
        startProgressTimer()
    }
    
    public func playSong() {
        startProgressTimer()
        play()
    }
    
    public func pauseSong() {
        cancelProgressTimer()
        pause()
    }
    
    private func startProgressTimer() {
        if progressTimer == nil {
            progressTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(handleSongProgress), userInfo: nil, repeats: true)
        }
    }
    
    public func cancelProgressTimer() {
        Swift.print("Canceled")
        if progressTimer != nil {
            progressTimer!.invalidate()
            progressTimer = nil
        }
    }
    
    public func updateSong(id: String) -> ApiEndpointsHelpers.PromiseEl? {
        updateSongPromiseConstructor = Promise<Any>.pending()
        guard let url = GeneralHelpers.getSongUrl(id: id) else { return nil }
        
        //        player.currentItem?.removeObserver(self, forKeyPath: "status")
        
        let playerItem = AVPlayerItem(url: url)
        replaceCurrentItem(with: playerItem)
        //        player.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        setTime(time: 0)
        return (updateSongPromiseConstructor.promise, { self.updateSongPromiseConstructor.reject(NSError.cancelledError()) })
    }
}

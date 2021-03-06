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
    
    init(onProgress: OnProgress? = nil, onSongStartedPlaying: EmptyCallback? = nil, onSongPaused: EmptyCallback? = nil, onSongFinished: EmptyCallback? = nil) {
        super.init()
        self.onProgress = onProgress
        self.onSongStartedPlaying = onSongStartedPlaying
        self.onSongPaused = onSongPaused
        self.onSongFinished = onSongFinished
        volume = 1
        addObserver(self, forKeyPath: "rate", options: .new, context: nil)
    }
    
    deinit {
        removeObserver(self, forKeyPath: "rate")
    }
    
    // MARK: - Private Methods
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if (rate == 0.0) {
                // Playback stopped

                guard let duration = self.currentItem?.duration else { return }
                if Float64.abs(CMTimeGetSeconds(self.currentTime()) - CMTimeGetSeconds(duration)) < 0.05 {
                    onSongFinished?()
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
    
    // MARK: - API Methods
    
    public func setTime(time: Double) {
        guard let currentItem = currentItem else { return }
        currentItem.seek(to: CMTime(seconds: time, preferredTimescale: 1))
        startProgressTimer()
    }
    
    public override func play() {
        super.play()
        isPlaying = true
        startProgressTimer()
        onSongStartedPlaying?()
    }
    
    public override func pause() {
        super.pause()
        isPlaying = false
        cancelProgressTimer()
        onSongPaused?()
    }
    
    public func stop() {
        setTime(time: 0)
        pause()
    }
    
    private func startProgressTimer() {
        if progressTimer == nil {
            progressTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(handleSongProgress), userInfo: nil, repeats: true)
        }
    }
    
    public func cancelProgressTimer() {
        if progressTimer != nil {
            progressTimer!.invalidate()
            progressTimer = nil
        }
    }
    
    public func updateSong(id: String) -> ApiEndpointsHelpers.PromiseEl? {
        updateSongPromiseConstructor = Promise<Any>.pending()
        guard let url = GeneralHelpers.getSongUrl(id: id) else { return nil }

        let playerItem = AVPlayerItem(url: url)
        replaceCurrentItem(with: playerItem)
        setTime(time: 0)
        return (updateSongPromiseConstructor.promise, { self.updateSongPromiseConstructor.reject(NSError.cancelledError()) })
    }
}

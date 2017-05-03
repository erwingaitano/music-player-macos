//
//  Sidebar.swift
//  music-player-macos
//
//  Created by Erwin GO on 5/1/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

class Sidebar: View {
    // MARK: - Typealiases

    typealias OnItemClick = (_ type: Kind, _ id: String) -> Void

    // MARK: - Enums

    enum Kind {
        case library, playlists
    }

    // MARK: - Properties

    private var items: [Kind: Any] = [:]
    private var onItemClick: OnItemClick?
    private var contentStackViewEl: NSStackView!

    private lazy var contentViewEl: View = {
        let v = View()
        v.layer?.backgroundColor = NSColor.black.cgColor

        self.contentStackViewEl = NSStackView()
        self.contentStackViewEl.orientation = .vertical
        self.contentStackViewEl.alignment = .left

        let libraryEl = Label()
        libraryEl.stringValue = "Library"

        let playlistsEl = Label()
        playlistsEl.stringValue = "Playlists"

        self.contentStackViewEl.addArrangedSubview(libraryEl)
        self.contentStackViewEl.addArrangedSubview(playlistsEl)

        v.addSubview(self.contentStackViewEl)
        self.contentStackViewEl.allEdgeAnchorsToEqual(v)

        return v
    }()

    private var scrollContainerEl: NSScrollView = {
        let v = NSScrollView()
        v.scrollerKnobStyle = .light
        v.hasVerticalScroller = true
        return v
    }()

    // MARK: - Inits

    init(items: [Kind: [Any]], onItemClick: OnItemClick?) {
        super.init()
        self.items = items
        self.onItemClick = onItemClick

        scrollContainerEl.documentView = contentViewEl
        contentViewEl.allEdgeAnchorsToEqual(scrollContainerEl)

        addSubview(scrollContainerEl)
        scrollContainerEl.backgroundColor = .black
        scrollContainerEl.allEdgeAnchorsToEqual(self)

        let libraryEl = getLibraryItems()
        contentStackViewEl.insertArrangedSubview(libraryEl, at: 1)
        libraryEl.widthAnchorToEqual(anchor: contentStackViewEl.widthAnchor)

        let playlistEl = getPlaylistsItems()
        contentStackViewEl.insertArrangedSubview(playlistEl, at: 2)
        playlistEl.widthAnchorToEqual(anchor: contentStackViewEl.widthAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private func getLibraryItems() -> NSStackView {
        let sv = NSStackView()
        sv.orientation = .vertical
        sv.alignment = .left
        sv.distribution = .fillEqually

        if let libraryItems = items[.library] as? [(id: String, name: String)] {
            libraryItems.enumerated().forEach { (i, el) in
                let item = NSButton()
                item.title = el.name
                item.heightAnchorToEqual(height: 40)
                item.tag = i
                item.target = self
                item.action = #selector(self.handleLibraryItemClick(button:))
                sv.addArrangedSubview(item)
            }
        }

        return sv
    }

    private func getPlaylistsItems() -> NSStackView {
        let sv = NSStackView()
        sv.orientation = .vertical
        sv.alignment = .left
        sv.distribution = .fillEqually

        if let playlistsItems = items[.playlists] as? [PlaylistModel] {
            playlistsItems.enumerated().forEach { (i, el) in
                let item = NSButton()
                item.title = el.name
                item.heightAnchorToEqual(height: 40)
                item.tag = i
                item.target = self
                item.action = #selector(self.handlePlaylistItemClick(button:))
                item.wantsLayer = true
                item.isBordered = false
                item.layer?.backgroundColor = NSColor.red.cgColor
                
                sv.addArrangedSubview(item)
                item.widthAnchorToEqual(anchor: sv.widthAnchor)
            }
        }

        return sv
    }

    @objc private func handleLibraryItemClick(button: NSButton) {
        Swift.print(button.tag)
        let item = (items[.library] as! [(id: String, name: String)])[button.tag]
        onItemClick?(Kind.library, item.id)
    }

    @objc private func handlePlaylistItemClick(button: NSButton) {
        let item = (items[.playlists] as! [PlaylistModel])[button.tag]
        onItemClick?(Kind.playlists, item.id)
    }

    // MARK: - API Methods

    public func updatePlaylists(_ playlists: [PlaylistModel]) {
        items[.playlists] = playlists
        contentStackViewEl.removeArrangedSubview(contentStackViewEl.arrangedSubviews[2])
        
        let playlistEl = getPlaylistsItems()
        contentStackViewEl.insertArrangedSubview(playlistEl, at: 3)
        playlistEl.widthAnchorToEqual(anchor: contentStackViewEl.widthAnchor)
    }
}

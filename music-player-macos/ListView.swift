//
//  ListView.swift
//  music-player-macos
//
//  Created by Erwin GO on 4/28/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

class ListView: View, NSTableViewDelegate, NSTableViewDataSource {
    // MARK: - Typealiases
    
    typealias OnItemSelected = (_ item: MediaCell.Data) -> Void
    typealias EmptyCallback = () -> Void
    
    // MARK: - Properties
    
    private let cellId = "cellId"
    private var onItemSelected: OnItemSelected?
    private var onCloseClick: EmptyCallback?
    private var data: [MediaCell.Data] = []
    
    private var tableEl: NSTableView = {
        let v = NSTableView()
        v.backgroundColor = .black
        return v
    }()
    
    private lazy var closeBtnEl: NSButton = {
        let v = NSButton()
//        v.addTarget(self, action: #selector(self.handleCloseClick), for: .touchUpInside)

        v.image = #imageLiteral(resourceName: "icon - arrowdown")
        v.widthAnchorToEqual(width: 25)
        v.heightAnchorToEqual(height: 17)
        return v
    }()
    
    private var titleEl: NSTextField = {
        let v = NSTextField()
        v.font = NSFont.boldSystemFont(ofSize: 30)
        v.stringValue = "-"
        v.textColor = .white
        return v
    }()
    
    // MARK: - Inits
    
    init(_ title: String, onItemSelected: OnItemSelected?, onCloseClick: EmptyCallback?) {
        super.init(frame: .zero)
        self.onItemSelected = onItemSelected
        self.onCloseClick = onCloseClick
        self.titleEl.stringValue = title
        layer?.backgroundColor = NSColor.yellow.cgColor
        tableEl.delegate = self
        tableEl.dataSource = self
//        tableEl.register(MediaCell.self, forIdentifier: cellId)
        layer?.backgroundColor = NSColor.black.cgColor
        
        addSubview(titleEl)
        titleEl.topAnchorToEqual(topAnchor, constant: 30)
        titleEl.leftAnchorToEqual(leftAnchor, constant: 20)
        
        addSubview(closeBtnEl)
        closeBtnEl.centerYAnchorToEqual(titleEl.centerYAnchor)
        closeBtnEl.rightAnchorToEqual(rightAnchor, constant: -19)
        
        addSubview(tableEl)
        tableEl.topAnchorToEqual(titleEl.bottomAnchor, constant: 20)
        tableEl.leftAnchorToEqual(leftAnchor)
        tableEl.rightAnchorToEqual(rightAnchor)
        tableEl.bottomAnchorToEqual(bottomAnchor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    @objc private func handleCloseClick() {
        onCloseClick?()
    }
    
    // MARK: - API Methods
    
    public func updateData(_ data: [MediaCell.Data]) {
        self.data = data
        tableEl.reloadData()
    }
    
    public static func getMediaCellDataArrayFromSongModelArray(_ songs: [SongModel]) -> [MediaCell.Data] {
        return songs.map { song -> MediaCell.Data in
            let imageUrl = song.allCovers.count == 0 ? nil : song.allCovers[0]
            return MediaCell.Data(id: song.id, title: song.name, subtitle: GeneralHelpers.getAlbumArtist(album: song.album, artist: song.artist), imageUrl: imageUrl)
        }
    }
    
    public static func getMediaCellDataArrayFromPlaylistModelArray(_ playlists: [PlaylistModel]) -> [MediaCell.Data] {
        return playlists.map { playlist -> MediaCell.Data in
            MediaCell.Data(id: playlist.id, title: playlist.name, subtitle: "Playlist", imageUrl: nil)
        }
    }
    
    // MARK: - Delegates
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 59
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let v = View()
        v.layer?.backgroundColor = NSColor.blue.cgColor
        v.frame = NSMakeRect(0, 0, 30, 30)
        return v
    }

//    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
//        let cell = MediaCell()
//        let data = self.data[row]
//        cell.data = data
//        return cell
//    }
//    
//    func tableView(_ tableView: NSTableView, didHighlightRowAt indexPath: IndexPath) {
//        (tableView.cellForRow(at: indexPath) as! MediaCell).highlight()
//    }
//    
//    func tableView(_ tableView: NSTableView, didUnhighlightRowAt indexPath: IndexPath) {
//        (tableView.cellForRow(at: indexPath) as! MediaCell).highlight(false)
//    }
//    
//    func tableView(_ tableView: NSTableView, didSelectRowAt indexPath: IndexPath) {
//        onItemSelected?(data[indexPath.row])
//    }
}


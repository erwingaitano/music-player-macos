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
    private var data: [MediaCell.Data] = []
    private var specialHighlightedCells: [String] = []
    private var scrollContainerEl: NSScrollView = {
        let v = NSScrollView()
        v.scrollerKnobStyle = .light
        v.hasVerticalScroller = true
        return v
    }()
    
    private var tableEl: NSTableView = {
        let v = NSTableView()
        let column = NSTableColumn()
        v.backgroundColor = .black
        v.addTableColumn(column)
        v.intercellSpacing = NSSize(width: 0, height: 0)
        
        var frame = v.headerView!.frame
        frame.size.height = 0
        v.headerView!.frame = frame
        return v
    }()
    
    private var titleEl: NSTextField = {
        let v = NSTextField()
        v.isEditable = false
        v.backgroundColor = .clear
        v.isBordered = false
        v.font = NSFont.boldSystemFont(ofSize: 30)
        v.stringValue = "-"
        v.textColor = .white
        return v
    }()
    
    // MARK: - Inits
    
    init(_ title: String, onItemSelected: OnItemSelected?) {
        super.init(frame: .zero)
        self.onItemSelected = onItemSelected
        self.titleEl.stringValue = title
        tableEl.delegate = self
        tableEl.dataSource = self
        tableEl.doubleAction = #selector(handleDoubleClick)
//        tableEl.action = #selector(handleDoubleClick)
        scrollContainerEl.documentView = tableEl
        
        layer?.backgroundColor = NSColor.black.cgColor
        
        addSubview(titleEl)
        titleEl.topAnchorToEqual(topAnchor, constant: 30)
        titleEl.leftAnchorToEqual(leftAnchor, constant: 20)
        
        addSubview(scrollContainerEl)
        scrollContainerEl.topAnchorToEqual(titleEl.bottomAnchor, constant: 20)
        scrollContainerEl.leftAnchorToEqual(leftAnchor)
        scrollContainerEl.rightAnchorToEqual(rightAnchor)
        scrollContainerEl.bottomAnchorToEqual(bottomAnchor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    @objc private func handleDoubleClick() {
        onItemSelected?(data[tableEl.selectedRow])
    }
    
    // MARK: - API Methods
    
    public func updateTitle(_ title: String) {
        titleEl.stringValue = title
    }
    
    public func updateData(_ data: [MediaCell.Data]) {
        self.data = data.map { el -> MediaCell.Data in
            var newData = el
            newData.isSpecialHighlighted = specialHighlightedCells.contains(el.id)
            return newData
        }
        
        tableEl.reloadData()
    }
    
    public static func getMediaCellDataArrayFromSongModelArray(_ songs: [SongModel]) -> [MediaCell.Data] {
        return songs.map { song -> MediaCell.Data in
            let imageUrl = song.allCovers.count == 0 ? nil : song.allCovers[0]
            return MediaCell.Data(id: song.id, title: song.name, subtitle: GeneralHelpers.getAlbumArtist(album: song.album, artist: song.artist), imageUrl: imageUrl, isSpecialHighlighted: false)
        }
    }
    
    public func updateSpecialHighlightedCells(ids: [String]) {
        specialHighlightedCells = ids
        updateData(data)
    }
    
    // MARK: - Delegates
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // TODO: this seems to not be working, it's always entering the if block
        var v = tableView.make(withIdentifier: "lul", owner: self) as? MediaCell
        
        if v == nil {
            v = MediaCell()
            v!.identifier = "lul"
        }
        
        v?.data = data[row]
        return v
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let table = notification.object as? NSTableView {
            let selected = table.selectedRowIndexes.map { Int($0) }
            Swift.print(selected)
        }
    }

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


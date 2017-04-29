//
//  MainController.swift
//  music-player-mac
//
//  Created by Erwin GO on 4/28/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

class MainController: NSViewController {
    // MARK: - Inits

    init() {
        super.init(nibName: nil, bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycles
    
    override func loadView() {
        self.view = View()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer?.backgroundColor = NSColor.black.cgColor
        let title = NSTextField()
        title.isEditable = false
        title.stringValue = "Does this work"
        title.isBordered = false
        title.font = NSFont.systemFont(ofSize: 18)
        title.textColor = .blue
        
        _ = ApiEndpointsHelpers.getSongs().promise.then { songs -> Void in
            //
        }
        
        let player = Player()
        view.addSubview(player)
        player.topAnchorToEqual(view.topAnchor)
        player.bottomAnchorToEqual(view.bottomAnchor)
        player.rightAnchorToEqual(view.rightAnchor)
        player.widthAnchorToEqual(anchor: view.widthAnchor, multiplier: 0.4)
        
        let songsListEl = ListView("ERWIN", onItemSelected: nil, onCloseClick: nil)
        view.addSubview(songsListEl)
        songsListEl.topAnchorToEqual(view.topAnchor)
        songsListEl.bottomAnchorToEqual(view.bottomAnchor)
//        songsListEl.heightAnchorToEqual(anchor: view.heightAnchor)
        songsListEl.leftAnchorToEqual(view.leftAnchor)
        songsListEl.rightAnchorToEqual(player.leftAnchor)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func keyDown(with event: NSEvent) {
        Swift.print("ERWINNNNNNNNNNNNNNNNNNN")
    }
}


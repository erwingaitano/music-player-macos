//
//  MediaCell.swift
//  music-player-macos
//
//  Created by Erwin GO on 4/28/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa
import Kingfisher

class MediaCell: NSTableRowView {
    // MARK: - Structs
    
    struct Data {
        var id: String
        var title: String
        var subtitle: String
        var imageUrl: String?
    }
    
    // MARK: - Properties
    
    public var data: Data! {
        didSet {
            titleEl.stringValue = data.title
            subtitleEl.stringValue = data.subtitle
            setImage(data.imageUrl)
        }
    }
    
    private var containerEl: View = {
        let v = View()
        v.layer?.backgroundColor = NSColor.black.cgColor
        return v
    }()
    
    private var imageEl: NSImageView = {
        let v = NSImageView()
//        v.contentMode = .scaleAspectFill
//        v.clipsToBounds = true
        v.layer?.backgroundColor = NSColor.hexStringToColor(hex: "#D8D8D8").cgColor
        return v
    }()
    
    private var titleEl: NSTextField = {
        let v = NSTextField()
        v.textColor = .white
        v.font = NSFont.systemFont(ofSize: 15)
        v.stringValue = "..."
        return v
    }()
    
    private var subtitleEl: NSTextField = {
        let v = NSTextField()
        v.textColor = .secondaryColor
        v.font = NSFont.systemFont(ofSize: 14)
        v.stringValue = "..."
        return v
    }()
    
    private var separatorEl: View = {
        let v = View()
        v.layer?.backgroundColor = NSColor.hexStringToColor(hex: "#2f2f2f").cgColor
        v.heightAnchorToEqual(height: 1)
        return v
    }()
    
    // MARK: - Inits
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        addSubview(containerEl)
        allEdgeAnchorsToEqual(self)
        
        addSubview(separatorEl)
        separatorEl.bottomAnchorToEqual(containerEl.bottomAnchor)
        separatorEl.leftAnchorToEqual(containerEl.leftAnchor)
        separatorEl.rightAnchorToEqual(containerEl.rightAnchor)
        
        addSubview(imageEl)
        imageEl.widthAnchorToEqual(width: 42)
        imageEl.heightAnchorToEqual(height: 42)
        imageEl.centerYAnchorToEqual(containerEl.centerYAnchor)
        imageEl.leftAnchorToEqual(containerEl.leftAnchor, constant: 8)
        
        addSubview(titleEl)
        titleEl.heightAnchorToEqual(height: 18)
        titleEl.topAnchorToEqual(imageEl.topAnchor, constant: 4)
        titleEl.leftAnchorToEqual(imageEl.rightAnchor, constant: 8)
        
        addSubview(subtitleEl)
        subtitleEl.heightAnchorToEqual(height: 18)
        subtitleEl.topAnchorToEqual(titleEl.bottomAnchor, constant: 4)
        subtitleEl.leftAnchorToEqual(titleEl.leftAnchor)
    }
    
    // MARK: - Private Methods
    
    private func setImage(_ imageUrl: String?) {
        if let imageUrl = imageUrl {
            imageEl.kf.setImage(with: URL(string: GeneralHelpers.getCoverUrl(imageUrl)))
        } else {
            imageEl.image = nil
        }
    }
    
    // MARK: - API Methods
    
    public func highlight(_ isHighlighted: Bool = true) {
        if isHighlighted {
            containerEl.layer?.backgroundColor = NSColor.hexStringToColor(hex: "#333333").cgColor
        } else {
            containerEl.layer?.backgroundColor = NSColor.black.cgColor
        }
    }
}


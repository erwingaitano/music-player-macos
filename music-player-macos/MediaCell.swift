//
//  MediaCell.swift
//  music-player-macos
//
//  Created by Erwin GO on 4/28/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa
import Kingfisher

class MediaCell: View {
    // MARK: - Structs
    
    struct Data {
        var id: String
        var title: String
        var subtitle: String
        var imageUrl: String?
        var isSpecialHighlighted: Bool
    }
    
    // MARK: - Properties
    
    public var data: Data! {
        didSet {
            titleEl.stringValue = data.title
            subtitleEl.stringValue = data.subtitle
            setImage(data.imageUrl)
            setSpecialHighlighted(data.isSpecialHighlighted)
        }
    }
    
    private var containerEl: View = {
        let v = View()
        return v
    }()
    
    private var imageEl: NSImageView = {
        let v = NSImageView()
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.hexStringToColor(hex: "#D8D8D8").cgColor
        return v
    }()
    
    private var titleEl: Label = {
        let v = Label()
        v.font = NSFont.systemFont(ofSize: 14)
        v.cell?.lineBreakMode = .byTruncatingTail
        v.stringValue = "..."
        return v
    }()
    
    private var subtitleEl: Label = {
        let v = Label()
        v.textColor = .secondaryColor
        v.font = NSFont.systemFont(ofSize: 13)
        v.cell?.lineBreakMode = .byTruncatingTail
        v.stringValue = "..."
        return v
    }()
    
    private lazy var contentEl: View = {
        let v = View()
        v.addSubview(self.titleEl)
        self.titleEl.heightAnchorToEqual(height: 18)
        self.titleEl.topAnchorToEqual(v.topAnchor)
        self.titleEl.leftAnchorToEqual(v.leftAnchor)
        self.titleEl.rightAnchorToEqual(v.rightAnchor)
        
        v.addSubview(self.subtitleEl)
        self.subtitleEl.heightAnchorToEqual(height: 18)
        self.subtitleEl.topAnchorToEqual(self.titleEl.bottomAnchor, constant: 4)
        self.subtitleEl.leftAnchorToEqual(v.leftAnchor)
        self.subtitleEl.rightAnchorToEqual(v.rightAnchor)
        
        v.bottomAnchorToEqual(self.subtitleEl.bottomAnchor)
        
        return v
    }()
    
    private var separatorEl: View = {
        let v = View()
        v.layer?.backgroundColor = NSColor.hexStringToColor(hex: "#2f2f2f").cgColor
        v.heightAnchorToEqual(height: 1)
        return v
    }()
    
    // MARK: - Inits
    
    override init() {
        super.init()
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        addSubview(containerEl)
        containerEl.allEdgeAnchorsToEqual(self)
        
        addSubview(separatorEl)
        separatorEl.bottomAnchorToEqual(containerEl.bottomAnchor)
        separatorEl.leftAnchorToEqual(containerEl.leftAnchor)
        separatorEl.rightAnchorToEqual(containerEl.rightAnchor)
        
        addSubview(imageEl)
        imageEl.topAnchorToEqual(containerEl.topAnchor, constant: 8)
        imageEl.bottomAnchorToEqual(containerEl.bottomAnchor, constant: -8)
        imageEl.widthAnchorToEqual(anchor: imageEl.heightAnchor)
        imageEl.leftAnchorToEqual(containerEl.leftAnchor, constant: 8)
        
        addSubview(contentEl)
        contentEl.centerYAnchorToEqual(imageEl.centerYAnchor)
        contentEl.leftAnchorToEqual(imageEl.rightAnchor, constant: 8)
        contentEl.rightAnchorToEqual(containerEl.rightAnchor, constant: -8)
    }
    
    // MARK: - Private Methods
    
    private func setImage(_ imageUrl: String?) {
        if let imageUrl = imageUrl {
            imageEl.kf.setImage(with: URL(string: GeneralHelpers.getCoverUrl(imageUrl)))
        } else {
            imageEl.image = nil
        }
    }
    
    private func setSpecialHighlighted(_ isSpecialHighlighted: Bool) {
        if isSpecialHighlighted {
            containerEl.layer?.backgroundColor = NSColor.hexStringToColor(hex: "#4ADD8C").cgColor
        } else {
            containerEl.layer?.backgroundColor = NSColor.clear.cgColor
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


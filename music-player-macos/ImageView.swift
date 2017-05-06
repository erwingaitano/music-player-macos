//
//  Image.swift
//  music-player-macos
//
//  Created by Erwin GO on 5/5/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

class ImageView: NSImageView {
    // MARK: - Enums

    enum BackgroundSizeOptions {
        case none, cover
    }
    
    // MARK: - Properties
    
    public var backgroundSize: BackgroundSizeOptions = .cover
    
    override var image: NSImage? {
        didSet {
            switch backgroundSize {
            case .cover:
                setImageAsSizeCover()
            default: return
            }
        }
    }
    
    // MARK: - Inits

    init() {
        super.init(frame: .zero)
        wantsLayer = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required convenience init(imageLiteralResourceName name: String) {
        fatalError("init(imageLiteralResourceName:) has not been implemented")
    }
    
    required init?(pasteboardPropertyList propertyList: Any, ofType type: String) {
        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }
    
    // MARK: - Life Cycles

    override func draw(_ dirtyRect: NSRect) {
        if backgroundSize == .cover {
            frame.size = dirtyRect.size
            setImageAsSizeCover()
        }
        super.draw(dirtyRect)
    }
    
    // MARK: - Private Methods
    
    private func setImageAsSizeCover() {
        guard let image = image else { return }
        
        let imageRealSize = GeneralHelpers.getRealImageSize(image)
        image.size = GeneralHelpers.getImageSizeToCoverContainer(imageSize: imageRealSize, containerSize: frame.size)
        imageScaling = .scaleNone
        imageAlignment = .alignCenter
    }
}

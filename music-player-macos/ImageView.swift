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
        frame.size = dirtyRect.size
        setImageAsSizeCover()
        super.draw(dirtyRect)
    }
    
    // MARK: - Private Methods
    
    private func setImageAsSizeCover() {
        guard let image = image else { return }
        
        let imageRealSize = getRealImageSize(image)
        image.size = getImageSizeToCoverContainer(imageSize: imageRealSize, containerSize: frame.size)
        
        // TODO: is this cacheMode necessary?
        //        image.cacheMode = .never
        imageScaling = .scaleNone
        imageAlignment = .alignCenter
    }
    
    private func getRealImageSize(_ image: NSImage) -> NSSize {
        var imageRealSize = image.size
        
        image.representations.forEach({ imageRep in
            let pixelsWide = CGFloat(imageRep.pixelsWide)
            let pixelsHigh = CGFloat(imageRep.pixelsHigh)
            if pixelsWide > imageRealSize.width { imageRealSize.width = pixelsWide }
            if pixelsHigh > imageRealSize.height { imageRealSize.height = pixelsHigh }
        })
        
        return imageRealSize
    }
    
    private func getImageSizeToCoverContainer(imageSize: NSSize, containerSize: NSSize) -> NSSize {
        let imageAspectRatio = imageSize.width / imageSize.height
        
        var newImageWidth = containerSize.width
        var newImageHeight = newImageWidth / imageAspectRatio
        
        if newImageHeight < containerSize.height {
            newImageHeight = containerSize.height
            newImageWidth = newImageHeight * imageAspectRatio
        }
        
        return NSSize(width: newImageWidth, height: newImageHeight)
    }
}

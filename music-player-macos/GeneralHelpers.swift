//
//  GeneralHelpers.swift
//  Squad
//
//  Created by Erwin GO on 2/24/17.
//  Copyright © 2017 Erwin GO. All rights reserved.
//

import Cocoa

class GeneralHelpers {
    public static func getJsonValueWithDotNotation(json: Any?, dotNotation: String) -> Any? {
        guard let json = json as? [String: Any] else { return nil }
        var lastDic: [String: Any]? = json
        var keys = dotNotation.components(separatedBy: ".")
        let lastKey = keys.popLast()
        for key in keys {
            if let newDic = json[key] as? [String: Any] { lastDic = newDic }
            else {
                lastDic = nil
                break
            }
        }
        
        guard let lastKeyUnwrapped = lastKey else { return nil }
        guard let value = lastDic?[lastKeyUnwrapped] else { return nil }
        return value
    }
    
    public static func getStringFromJsonDotNotation(json: Any?, dotNotation: String) -> String {
        let newInt = getJsonValueWithDotNotation(json: json, dotNotation: dotNotation) as! Int
        return String(newInt)
    }
    
    public static func getAlbumArtist(album: String?, artist: String?) -> String {
        var result: String
        if let artist = artist {
            result = artist
            if let album = album { result += " - \(album)" }
        } else if let album = album { result = album }
        else { result = "Artist Unknown" }
        return result
    }
    
    public static func mergeArrays(_ arrays: [Any]?...) -> [Any] {
        return arrays.reduce([]) { (result, el) -> [Any] in
            return result + (el ?? [])
        }
    }
    
    public static func getCoverUrl(_ url: String) -> String {
        return "\(AppSingleton.shared.mediaFolderPath)\(url)"
    }
    
    public static func getSongDirPathFromSongKeyname(_ keyname: String) -> String? {
        let objects = keyname.components(separatedBy: "~")
        var dirPath: String?
        
        if objects.count == 2 {
            dirPath = "\(AppSingleton.shared.mediaFolderPath)/_artists/\(objects[0])/\(objects[1])"
        } else if objects.count == 3 {
            dirPath = "\(AppSingleton.shared.mediaFolderPath)/_artists/\(objects[0])/_albums/\(objects[1])/\(objects[2])"
        }
        
        return dirPath
    }
    
    public static func getSongUrl(id: String) -> URL? {
        guard let song = AppSingleton.shared.songs.first(where: { $0.id == id }) else { return nil }
        guard let songExtension = song.ext else { return nil }
        guard let songDirPath = getSongDirPathFromSongKeyname(song.keyname) else { return nil }
        return URL(fileURLWithPath: "\(songDirPath)/file\(songExtension)")
    }
}

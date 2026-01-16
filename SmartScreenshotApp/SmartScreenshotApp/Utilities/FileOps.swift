//
//  FileOps.swift
//  SmartScreenshotApp
//
//  Created by timbo on 1/15/26.
//

import Foundation

struct FileOps {
    
    static func rename(url: URL, to name: String) throws -> URL {
        
        let folder = url.deletingLastPathComponent()
        let ext = url.pathExtension
        var newURL = folder.appendingPathComponent("\(name).\(ext)")
        
        // Collision handling: If "image_01.png" exists, try "image_01-2.png"
        var counter = 2
        
        while FileManager.default.fileExists(atPath: newURL.path) {
            
            newURL = folder.appendingPathComponent("\(name)-\(counter).\(ext)")
            counter += 1
        }
        
        try FileManager.default.moveItem(at: url, to: newURL)
        return newURL
    }
}

//
//  ScreenshotStream.swift
//  SmartScreenshotApp
//
//  Created by timbo on 1/15/26.
//

import Foundation
import Combine
import CoreServices

class ScreenshotStream: AsyncSequence {
    typealias Element = URL
    
    // main function
    func makeAsyncIterator() -> AsyncStream<URL>.Iterator {
        
        let stream = AsyncStream<URL> { continuation in
            
            let query = NSMetadataQuery()
            
            // Locate images specifically tagged by macOS as screen captures
            query.predicate = NSPredicate(format: "kMDItemIsScreenCapture = 1")
            
            // call helper function
            query.searchScopes = [getScreenshotLocation()]
            
            let observer = NotificationCenter.default.addObserver(
                
                forName: .NSMetadataQueryDidUpdate, object: query, queue: .main) { notification in
                query.disableUpdates()
                if let added = notification.userInfo?[NSMetadataQueryUpdateAddedItemsKey] as? [NSMetadataItem] {
                    let now = Date()
                    for item in added {
                        if let path = item.value(forAttribute: NSMetadataItemPathKey) as? String,
                           let created = item.value(forAttribute: "kMDItemContentCreationDate") as? Date,
                           now.timeIntervalSince(created) < 30 {
                            let url = URL(fileURLWithPath: path)
                            continuation.yield(url)
                        }
                    }
                }
                query.enableUpdates()
            }
            
            let gatherObserver = NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidFinishGathering, object: query, queue: .main) { _ in
                query.disableUpdates()
                let results = query.results as! [NSMetadataItem]
                let now = Date()
                for item in results {
                    if let path = item.value(forAttribute: NSMetadataItemPathKey) as? String,
                       let created = item.value(forAttribute: "kMDItemContentCreationDate") as? Date,
                       now.timeIntervalSince(created) < 30 {
                        let url = URL(fileURLWithPath: path)
                        continuation.yield(url)
                    }
                }
                query.enableUpdates()
            }
            
            query.start()
            
            continuation.onTermination = { _ in
                query.stop()
                NotificationCenter.default.removeObserver(observer)
                NotificationCenter.default.removeObserver(gatherObserver)
            }
        }
        
        return stream.makeAsyncIterator()
    }
    
    // Dynamically read screenshot save folder location and set as query scope
    func getScreenshotLocation() -> String {
        let defaults = UserDefaults(suiteName: "com.apple.screencapture")
        if let location = defaults?.string(forKey: "location") {
            let expanded = (location as NSString).expandingTildeInPath
            print("found screenshot save folder: \(expanded)")
            return expanded
        }
        let desktop = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first ?? NSHomeDirectory()
        print("found screenshot save folder: \(desktop)")
        return desktop
    }
    
}

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
    
    func makeAsyncIterator() -> AsyncStream<URL>.Iterator {
        
        let stream = AsyncStream<URL> { continuation in
            
            let query = NSMetadataQuery()
            
            // Locate images specifically tagged by macOS as screen captures
            query.predicate = NSPredicate(format: "kMDItemIsScreenCapture = 1")
            
            query.searchScopes = [NSMetadataQueryUserHomeScope]
            
            let observer = NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidUpdate, object: query, queue: .main) { _ in
                    
                query.disableUpdates()
                let results = query.results as! [NSMetadataItem]
                
                let now = Date()
                    
                for item in results {
                    
                    // Use direct string key for creation date
                    if let path = item.value(forAttribute: NSMetadataItemPathKey) as? String,
                       
                       let created = item.value(forAttribute: "kMDItemContentCreationDate") as? Date,
                       
                       now.timeIntervalSince(created) < 5 {
                        
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
            }
        }
        
        return stream.makeAsyncIterator()
    }
}

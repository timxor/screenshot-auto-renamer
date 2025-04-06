//
//  main.swift
//  screenshot-auto-renamer
//
//  Created by Tim Siwula on 4/5/25.
//
//  Run command: swift main.swift ~/Downloads
//

import Foundation
import CoreServices

print("screenshot-auto-renamer started watching directory = {arg1=~/Downloads}")

// Track detected paths
var seenPaths = Set<String>()

func startWatching(path: String) {
    let pathsToWatch = [path] as CFArray

    let callback: FSEventStreamCallback = { _, _, numEvents, eventPathsRaw, _, _ in
        let paths = eventPathsRaw.bindMemory(to: UnsafePointer<CChar>.self, capacity: numEvents)

        for i in 0..<numEvents {
            let cPath = paths[i]
            if let pathString = String(validatingUTF8: cPath) {
                // Skip this path if we've already seen it
                if seenPaths.contains(pathString) {
                    continue
                }

                // Add the path to the set to mark it as processed
                seenPaths.insert(pathString)

                print("Detected file: \(pathString)")
                if pathString.hasSuffix(".png") && pathString.contains("Screen Shot") {
                    print("📸 Screenshot detected: \(pathString)")
                    fflush(stdout)
                }
            }
        }
    }

    var context = FSEventStreamContext()

    guard let stream = FSEventStreamCreate(
        kCFAllocatorDefault,
        callback,
        &context,
        pathsToWatch,
        FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
        1.0,
        FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents)
    ) else {
        print("❌ Failed to create FSEventStream")
        return
    }

    let queue = DispatchQueue.global(qos: .default)
    FSEventStreamSetDispatchQueue(stream, queue)
    FSEventStreamStart(stream)

    dispatchMain() // Keeps the program running
}

if CommandLine.arguments.count < 2 {
    print("Usage: ScreenshotWatcher <path>")
    exit(1)
}

let watchPath = CommandLine.arguments[1]
startWatching(path: watchPath)

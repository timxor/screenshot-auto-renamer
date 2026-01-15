//
//  main.swift
//  screenshot-auto-renamer
//
//  Created by Tim Siwula on 4/5/25.
//
//  run: swift main.swift ~/Downloads
//
import Foundation
import CoreServices

print("screenshot-auto-renamer started")

// Global set to track already-seen paths
var seenPaths = Set<String>()

// Global watch path to avoid closure capture (required by FSEventStreamCallback)
var watchPath: String = ""

func startWatching(path: String) {
    // Set global so it can be accessed in the C-compatible callback
    watchPath = path

    let pathsToWatch = [path] as CFArray

    let callback: FSEventStreamCallback = { _, _, numEvents, eventPathsRaw, _, _ in
        let paths = eventPathsRaw.bindMemory(to: UnsafePointer<CChar>.self, capacity: numEvents)

        for i in 0..<numEvents {
            let cPath = paths[i]
            if let pathString = String(validatingUTF8: cPath) {
                // Skip hidden (dot-prefixed) files
                if pathString.hasPrefix(watchPath + "/.") {
                    continue
                }

                if seenPaths.contains(pathString) {
                    continue
                }

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

    dispatchMain() // Keep the CLI alive
}

if CommandLine.arguments.count < 2 {
    print("Usage: ScreenshotWatcher <path>")
    exit(1)
}

let inputPath = CommandLine.arguments[1]
startWatching(path: inputPath)

//
//  main.swift
//  screenshot-auto-renamer
//
//  Created by Tim Siwula on 4/5/25.
//
//  build binary file located at:
//      "/Users/timsiwula/Library/Developer/Xcode/DerivedData/screenshot-auto-renamer-diiiedxlicyypehgsezlmnmzhwjs/Build/Products/Debug/screenshot-auto-renamer"
//
//   copy it:
//      cp /Users/timsiwula/Library/Developer/Xcode/DerivedData/screenshot-auto-renamer-diiiedxlicyypehgsezlmnmzhwjs/Build/Products/Debug/screenshot-auto-renamer .
//
//   run it:
//      ./screenshot-auto-renamer ~/Downloads
//
//

//
//  main.swift
//  screenshot-auto-renamer

import Foundation
import CoreServices

print("screenshot-auto-renamer started")

func startWatching(path: String) {
    let pathsToWatch = [path] as CFArray

    let callback: FSEventStreamCallback = { _, _, numEvents, eventPathsRaw, _, _ in
        let paths = eventPathsRaw.bindMemory(to: UnsafePointer<CChar>.self, capacity: numEvents)

        for i in 0..<numEvents {
            let cPath = paths[i]
            if let pathString = String(validatingUTF8: cPath) {
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

    dispatchMain() // Keeps the CLI alive
}

if CommandLine.arguments.count < 2 {
    print("Usage: ScreenshotWatcher <path>")
    exit(1)
}

let watchPath = CommandLine.arguments[1]
startWatching(path: watchPath)

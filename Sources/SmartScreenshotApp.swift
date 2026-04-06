//
//  SmartScreenshotAppApp.swift
//  SmartScreenshotApp
//
//  Created by timbo on 1/15/26.
//

import os
import SwiftUI
import Observation

@MainActor
@Observable
class ScreenshotListener {
    
    private let renamer = SmartRenamer()
    private let logger = Logger(subsystem: "com.timsiwula.SmartScreenshotApp", category: "ScreenshotStream")

    
    init() {
        startListening()
    }
    
    func startListening() {
        Task {
            logger.info("1. SmartScreenshotApp is now Active in Menu Bar")
            // print("1. SmartScreenshotApp is now Active in Menu Bar")
            for await url in ScreenshotStream() {
                await processScreenshot(url)
            }
        }
    }
    
    func processScreenshot(_ url: URL) async {
        do {
            
            logger.info("2. Detected Screenshot: \(url.lastPathComponent)")
            // print("2. Detected Screenshot: \(url.lastPathComponent)")
            
            
            // 1. Ask the 'Brain' for a name
            let smartName = try await renamer.generateSmartName(for: url)
            
            // 2. Perform the file system move
            let newURL = try FileOps.rename(url: url, to: smartName)
            
            // print("3. Renamed screenshot to: \(newURL.lastPathComponent)")
            logger.info("3. Renamed screenshot to: \(newURL.lastPathComponent)")
            
        } catch {
            // print("3. Error processing screenshot: \(error)")
            logger.info("3. Error processing screenshot: \(error)")
        }
    }
}

@main
struct SmartScreenshotApp: App {
    @State private var listener = ScreenshotListener()
    
    var body: some Scene {
        MenuBarExtra("SmartScreen", systemImage: "sparkles.rectangle.stack") {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

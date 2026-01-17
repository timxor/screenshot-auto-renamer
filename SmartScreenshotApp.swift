//
//  SmartScreenshotAppApp.swift
//  SmartScreenshotApp
//
//  Created by timbo on 1/15/26.
//

import SwiftUI
import Observation

@MainActor
@Observable
class ScreenshotListener {
    private let renamer = SmartRenamer()
    
    init() {
        startListening()
    }
    
    func startListening() {
        Task {
            print("1. SmartScreenshotApp is now Active in Menu Bar")
            for await url in ScreenshotStream() {
                await processScreenshot(url)
            }
        }
    }
    
    func processScreenshot(_ url: URL) async {
        do {
            print("2. Detected Screenshot: \(url.lastPathComponent)")
            
            // 1. Ask the 'Brain' for a name
            let smartName = try await renamer.generateSmartName(for: url)
            
            // 2. Perform the file system move
            let newURL = try FileOps.rename(url: url, to: smartName)
            
            print("2.1. Renamed screenshot to: \(newURL.lastPathComponent)")
        } catch {
            print("2.2. Error processing screenshot: \(error)")
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

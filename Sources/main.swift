import Foundation
import AppKit

class ScreenshotCapture {

    private let fileManager = FileManager.default
    private var screenshotFolderURL: URL!
    private var source: DispatchSourceFileSystemObject?
    private var keyboardMonitor: Any?

    enum CaptureType {
        case full
        case selection
    }

    init() {
        setupScreenshotFolder()
        setupKeyboardMonitoring()
    }

    private func setupScreenshotFolder() {
        // Get screenshot location from system defaults
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["read", "com.apple.screencapture", "location"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                let expandedPath = NSString(string: path).expandingTildeInPath
                screenshotFolderURL = URL(fileURLWithPath: expandedPath)
            } else {
                // Fallback to Desktop
                screenshotFolderURL = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Desktop")
            }
            
            // Verify folder exists
            var isDirectory: ObjCBool = false
            if !fileManager.fileExists(atPath: screenshotFolderURL.path, isDirectory: &isDirectory) {
                print("Screenshot folder doesn't exist: \(screenshotFolderURL.path)")
                // Fallback to Downloads
                screenshotFolderURL = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Downloads")
            }
            
            print("Using screenshot folder: \(screenshotFolderURL.path)")
        } catch {
            print("Error reading screenshot location: \(error)")
            // Fallback to Downloads
            screenshotFolderURL = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Downloads")
        }
    }

    private func setupKeyboardMonitoring() {
        keyboardMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains([.command, .shift]) {
                if event.keyCode == 3 { // Command-Shift-3
                    print("Full screenshot command detected")
                    self?.captureScreen(type: .full)
                } else if event.keyCode == 4 { // Command-Shift-4
                    print("Selection screenshot command detected")
                    self?.captureScreen(type: .selection)
                }
            }
        }
    }

    func captureScreen(type: CaptureType) {
        switch type {
        case .full:
            guard let cgImage = CGDisplayCreateImage(CGMainDisplayID()) else {
                print("Could not capture screen")
                return
            }
            saveScreenshot(cgImage)
            
        case .selection:
            // Implement selection capture logic
            print("Selection capture not implemented yet")
        }
    }

    private func saveScreenshot(_ cgImage: CGImage) {
        let bitmap = NSBitmapImageRep(cgImage: cgImage)
        guard let imageData = bitmap.representation(using: .png, properties: [:]) else {
            print("Could not create PNG data")
            return
        }
        
        let filename = screenshotFolderURL.appendingPathComponent("Screenshot-\(Date()).png")
        do {
            try imageData.write(to: filename)
            print("Screenshot saved to: \(filename.path)")
        } catch {
            print("Error saving screenshot: \(error)")
        }
    }
    
    private func generateScreenshotFilename() -> URL {
        let activeApp = NSWorkspace.shared.frontmostApplication
        let appName = activeApp?.localizedName ?? "Unknown"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        
        let filename = "\(appName)_\(timestamp).png"
        let documentsDirectory = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(filename)
    }

    deinit {
        if let monitor = keyboardMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
}

@main
struct ScreenshotApp {
    static func main() {
        let capture = ScreenshotCapture()
        
        // Keep the app running to listen for events
        RunLoop.current.run()
    }
}


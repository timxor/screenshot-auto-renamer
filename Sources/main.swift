import Foundation
import AppKit

class ScreenshotCapture {
    
    func captureScreen() {
        guard let screen = NSScreen.main,
              let cgImage = CGDisplayCreateImage(CGMainDisplayID()) else {
            print("Could not capture screen")
            return
        }
        
        let bitmap = NSBitmapImageRep(cgImage: cgImage)
        let imageData = bitmap.representation(using: .png, properties: [:])
        
        let filename = generateScreenshotFilename()
        
        do {
            try imageData?.write(to: filename)
            print("Screenshot saved to: \(filename.path)")
        } catch {
            print("Failed to save screenshot: \(error)")
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
    
    
}

@main
struct ScreenshotApp {
    static func main() {
        let capture = ScreenshotCapture()
        capture.captureScreen()
    }
}


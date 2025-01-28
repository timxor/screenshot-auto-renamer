import Foundation
import Carbon

// Function to handle key events
func keyboardEventHandler(_ proxy: CGEventTapProxy, _ type: CGEventType, _ event: CGEvent, _ refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    if type == .keyDown {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let keyChar = getCharacterFromKeyCode(keyCode)
        print("Keyboard event: '\(keyChar)' key was pressed")
    }
    return Unmanaged.passRetained(event)
}


// Function to convert key code to character
func getCharacterFromKeyCode(_ keyCode: Int64) -> String {
    let source = TISCopyCurrentASCIICapableKeyboardLayoutInputSource().takeRetainedValue()
    let layoutData = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData)
    let dataRef = unsafeBitCast(layoutData, to: CFData.self)
    let keyLayout = unsafeBitCast(CFDataGetBytePtr(dataRef), to: UnsafePointer<UCKeyboardLayout>.self)

    var deadKeyState: UInt32 = 0
    var stringLength = 0
    var unicodeString = [UniChar](repeating: 0, count: 4)

    UCKeyTranslate(keyLayout,
                   UInt16(keyCode),
                   UInt16(kUCKeyActionDisplay),
                   0,
                   UInt32(LMGetKbdType()),
                   OptionBits(kUCKeyTranslateNoDeadKeysBit),
                   &deadKeyState,
                   4,
                   &stringLength,
                   &unicodeString)

    return String(utf16CodeUnits: unicodeString, count: stringLength)
}

// Set up the event tap
let eventMask = (1 << CGEventType.keyDown.rawValue)
guard let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                       place: .headInsertEventTap,
                                       options: .defaultTap,
                                       eventsOfInterest: CGEventMask(eventMask),
                                       callback: keyboardEventHandler,
                                       userInfo: nil) else {
    print("Failed to create event tap")
    exit(1)
}

// Create a run loop source and add it to the current run loop
let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)

// Enable the event tap
CGEvent.tapEnable(tap: eventTap, enable: true)

// Run the program until it's terminated
print("Listening for keyboard events. Press Ctrl+C to exit.")
CFRunLoopRun()

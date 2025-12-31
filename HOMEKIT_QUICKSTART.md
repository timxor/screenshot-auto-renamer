# HomeKit Integration Quick Start Guide

This guide will help you get started with HomeKit integration in the Screenshot Auto Renamer project.

## Prerequisites

Before you begin, ensure you have:

- ✅ **Xcode 11+** installed
- ✅ **macOS 10.15+** or **iOS 13.0+**
- ✅ **Apple Developer Account** (free or paid)
- ✅ **Physical iOS device** for testing (HomeKit has limited simulator support)
- ✅ **Home app** configured with at least one home

## Step-by-Step Setup

### 1. Enable HomeKit in Xcode

1. Open your project in Xcode
2. Select your app target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability"
5. Add "HomeKit"

### 2. Configure Entitlements

Your `App.entitlements` file should include:

```xml
<key>com.apple.developer.homekit</key>
<true/>
```

The entitlements file is already created at: `Resources/App.entitlements`

### 3. Update Info.plist

Add HomeKit usage description:

```xml
<key>NSHomeKitUsageDescription</key>
<string>This app uses HomeKit to automate screenshot renaming.</string>
```

The Info.plist file is already created at: `Resources/Info.plist`

### 4. Initialize HomeKit in Your App

```swift
import HomeKit

// In your app initialization
let homeKitManager = HomeKitManager.shared

// Wait for HomeKit to initialize
DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    if let home = homeKitManager.primaryHome {
        print("Connected to home: \(home.name)")
    }
}
```

### 5. Set Up Your Home (First Time)

On your iOS device:

1. Open the **Home** app
2. Tap "Add Accessory" to add HomeKit devices
3. Follow the pairing instructions
4. Organize accessories into rooms

### 6. Run Your First Example

Try the basic setup example:

```bash
cd /path/to/screenshot-auto-renamer
swift run
```

Or run specific examples:

```swift
// In your main.swift or test file
import Foundation
import HomeKit

// See Examples/BasicHomeKitSetup.swift
basicHomeKitSetup()
```

## Common First-Time Issues

### Issue: "No primary home found"

**Solution:**
- Open the Home app on your iOS device
- Create a new home or select an existing one
- Wait a few minutes for iCloud to sync

### Issue: "HomeKit authorization failed"

**Solution:**
- Check that `Info.plist` includes `NSHomeKitUsageDescription`
- Verify entitlements are properly configured
- Ensure your developer account is active

### Issue: "Cannot test on simulator"

**Solution:**
- Use a physical iOS or macOS device
- HomeKit requires actual hardware for most functionality

## Project Structure Overview

```
screenshot-auto-renamer/
├── HOMEKIT_INTEGRATION.md         # Full documentation
├── HOMEKIT_QUICKSTART.md          # This file
├── Sources/
│   └── HomeKit/                   # HomeKit implementation files
│       ├── HomeKitManager.swift   # Main manager
│       ├── AccessoryManager.swift # Accessory handling
│       ├── TriggerManager.swift   # Automation triggers
│       └── HomeManager.swift      # Home/room management
├── Examples/                      # Working examples
│   ├── BasicHomeKitSetup.swift   # Getting started
│   ├── AccessoryControl.swift    # Control devices
│   └── AutomationTriggers.swift  # Automations
├── Resources/                     # Configuration files
│   ├── App.entitlements          # Required entitlements
│   ├── Info.plist                # App configuration
│   └── HomeKitAccessories/       # Accessory definitions
└── Tests/
    └── HomeKitTests/             # Unit tests
```

## Next Steps

1. **Explore Examples**: Check out the files in the `Examples/` directory
2. **Read Full Documentation**: See `HOMEKIT_INTEGRATION.md` for complete details
3. **Test with Real Devices**: Add HomeKit accessories to experiment
4. **Implement Integration**: Connect HomeKit events to screenshot functionality

## Simple Test Script

Create a test file `test_homekit.swift`:

```swift
import Foundation
import HomeKit

print("Testing HomeKit Setup...")

let manager = HomeKitManager.shared

DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
    print("Homes found: \(manager.homes.count)")
    
    if let home = manager.primaryHome {
        print("✅ Primary home: \(home.name)")
        print("   Rooms: \(home.rooms.count)")
        print("   Accessories: \(home.accessories.count)")
        print("   Triggers: \(home.triggers.count)")
        
        print("\n✅ HomeKit is working!")
    } else {
        print("⚠️  No primary home configured")
        print("   Please set up a home in the Home app")
    }
    
    exit(0)
}

RunLoop.main.run()
```

Run it:
```bash
swift test_homekit.swift
```

## Useful Commands

```bash
# Build the project
swift build

# Run the app
swift run

# Run tests
swift test

# Clean build
swift package clean
```

## Getting Help

- **Full Documentation**: See `HOMEKIT_INTEGRATION.md`
- **Apple Documentation**: https://developer.apple.com/documentation/homekit
- **Code Examples**: Check the `Examples/` directory
- **Test Cases**: See `Tests/HomeKitTests/`

## Quick Reference

### Basic Operations

```swift
// Get primary home
let home = HomeKitManager.shared.primaryHome

// List accessories
let accessories = home?.accessories ?? []

// Find a light
let light = accessories.first { 
    $0.services.contains { $0.serviceType == HMServiceTypeLightbulb }
}

// Control the light
if let light = light,
   let service = light.services.first(where: { $0.serviceType == HMServiceTypeLightbulb }),
   let characteristic = service.characteristics.first(where: { $0.characteristicType == HMCharacteristicTypePowerState }) {
    
    characteristic.writeValue(true) { error in
        if let error = error {
            print("Error: \(error)")
        } else {
            print("Light turned on!")
        }
    }
}
```

## Security Reminders

- ✅ Never commit HomeKit credentials
- ✅ Use proper entitlements
- ✅ Request user permission clearly
- ✅ Handle errors gracefully
- ✅ Test on real devices

---

**Ready to start?** Open `Examples/BasicHomeKitSetup.swift` and begin exploring!

# HomeKit Project Structure Reference

## Directory Tree

```
screenshot-auto-renamer/
│
├── 📄 README.md                              # Main project README
├── 📄 HOMEKIT_INTEGRATION.md                 # Complete HomeKit guide (THIS IS THE MAIN GUIDE)
├── 📄 HOMEKIT_QUICKSTART.md                  # Quick start tutorial
├── 📄 HOMEKIT_STRUCTURE.md                   # This file - structure reference
├── 📄 Package.swift                          # Swift Package Manager config
├── 📄 LICENSE
├── 📄 .gitignore
│
├── 📁 Sources/                               # Source code
│   ├── 📁 App/                              # Application entry point
│   │   ├── main.swift                       # Main entry point
│   │   └── App.entitlements                 # App entitlements (optional location)
│   │
│   ├── 📁 Screenshot/                       # Screenshot functionality
│   │   └── ScreenshotCapture.swift          # Screenshot capture logic
│   │
│   └── 📁 HomeKit/                          # HomeKit integration (NEW)
│       ├── HomeKitManager.swift             # Main HomeKit manager
│       ├── AccessoryManager.swift           # Accessory discovery & control
│       ├── TriggerManager.swift             # Automation triggers
│       ├── HomeManager.swift                # Home & room management
│       ├── ScreenshotHomeKitIntegration.swift  # Integration bridge
│       │
│       └── 📁 Models/                       # Data models (optional)
│           ├── HomeKitAccessory.swift       # Accessory model
│           ├── HomeKitAction.swift          # Action model
│           └── HomeKitTrigger.swift         # Trigger model
│
├── 📁 Resources/                            # Resource files (NEW)
│   ├── App.entitlements                    # App entitlements
│   ├── Info.plist                          # App info & permissions
│   │
│   └── 📁 HomeKitAccessories/              # Accessory configurations
│       └── accessories.json                # Accessory definitions
│
├── 📁 Examples/                             # Example code (NEW)
│   ├── BasicHomeKitSetup.swift             # Basic setup example
│   ├── AccessoryControl.swift              # Accessory control examples
│   └── AutomationTriggers.swift            # Automation examples
│
├── 📁 Tests/                                # Test files
│   ├── 📁 HomeKitTests/                    # HomeKit tests (NEW)
│   │   ├── HomeKitManagerTests.swift       # Manager tests
│   │   └── AccessoryManagerTests.swift     # Accessory tests (included above)
│   │
│   └── 📁 ScreenshotTests/                 # Screenshot tests
│       └── ScreenshotCaptureTests.swift    # Capture tests
│
└── 📁 builds/                               # Build artifacts (gitignored)
    └── v2/
        └── screenshot-auto-renamer          # Compiled binary
```

## File Descriptions

### Core Files Created for HomeKit

| File | Purpose | Lines | Priority |
|------|---------|-------|----------|
| `HOMEKIT_INTEGRATION.md` | **Main documentation** - Complete guide | ~650 | ⭐⭐⭐ HIGH |
| `HOMEKIT_QUICKSTART.md` | Quick start tutorial | ~200 | ⭐⭐⭐ HIGH |
| `Resources/App.entitlements` | Required entitlements for HomeKit | ~30 | ⭐⭐⭐ REQUIRED |
| `Resources/Info.plist` | App permissions & configuration | ~100 | ⭐⭐⭐ REQUIRED |
| `Examples/BasicHomeKitSetup.swift` | Getting started example | ~100 | ⭐⭐ MEDIUM |
| `Examples/AccessoryControl.swift` | Accessory control examples | ~250 | ⭐⭐ MEDIUM |
| `Examples/AutomationTriggers.swift` | Automation examples | ~300 | ⭐⭐ MEDIUM |
| `Resources/HomeKitAccessories/accessories.json` | Accessory config reference | ~150 | ⭐ LOW |
| `Tests/HomeKitTests/HomeKitManagerTests.swift` | Unit tests | ~200 | ⭐ LOW |

### Files You Need to Create (Implementations)

These are referenced in the documentation but not created as actual source files:

| File | Purpose | Estimated Lines |
|------|---------|----------------|
| `Sources/HomeKit/HomeKitManager.swift` | Main HomeKit manager class | ~150 |
| `Sources/HomeKit/AccessoryManager.swift` | Accessory management | ~200 |
| `Sources/HomeKit/TriggerManager.swift` | Trigger management | ~150 |
| `Sources/HomeKit/HomeManager.swift` | Home/room management | ~100 |
| `Sources/HomeKit/ScreenshotHomeKitIntegration.swift` | Integration bridge | ~100 |

## Component Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Your Application                      │
│                       (main.swift)                       │
└────────────────────┬────────────────────────────────────┘
                     │
                     ├─────────────────────────────────────┐
                     │                                     │
        ┌────────────▼──────────┐          ┌─────────────▼────────────┐
        │  ScreenshotCapture    │          │   HomeKitManager         │
        │  (Existing)            │          │   (New)                  │
        │                        │          │                          │
        │  - captureScreen()     │◄─────────┤  - homes                 │
        │  - generateFilename()  │          │  - primaryHome           │
        └────────────────────────┘          │  - isAuthorized          │
                                            │  - requestAuthorization()│
                                            └─────────┬────────────────┘
                                                      │
                        ┌─────────────────────────────┼──────────────────────┐
                        │                             │                      │
            ┌───────────▼──────────┐    ┌────────────▼───────────┐  ┌──────▼────────────┐
            │  AccessoryManager    │    │   TriggerManager       │  │  HomeManager      │
            │                      │    │                        │  │                   │
            │  - startDiscovering()│    │  - createTimeTrigger() │  │  - createHome()   │
            │  - addAccessory()    │    │  - createEventTrigger()│  │  - createRoom()   │
            │  - controlAccessory()│    │  - createCharTrigger() │  │  - assignAccessory│
            └──────────────────────┘    └────────────────────────┘  └───────────────────┘
                        │
                        ▼
            ┌───────────────────────┐
            │   Apple HomeKit       │
            │   Framework           │
            │                       │
            │   - HMHomeManager     │
            │   - HMHome            │
            │   - HMAccessory       │
            │   - HMCharacteristic  │
            │   - HMTrigger         │
            └───────────────────────┘
```

## Data Flow

### Screenshot Capture with HomeKit Integration

```
User Action / HomeKit Trigger
         │
         ▼
┌─────────────────────┐
│  HomeKit Event      │  (e.g., light turns on, location change)
│  Detected           │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────────────┐
│  HomeKitManager             │
│  - Receives event           │
│  - Gets room context        │
└──────┬──────────────────────┘
       │
       ▼
┌─────────────────────────────┐
│  ScreenshotHomeKit          │
│  Integration                │
│  - Processes event          │
│  - Determines naming        │
└──────┬──────────────────────┘
       │
       ▼
┌─────────────────────────────┐
│  ScreenshotCapture          │
│  - Captures screen          │
│  - Applies HomeKit name     │
│  - Saves to disk            │
└─────────────────────────────┘
       │
       ▼
    Saved File:
    "Living-Room_Safari_2025-01-26_18-53-24.png"
```

## Getting Started Workflow

```
1. READ DOCUMENTATION
   ├── Start with: HOMEKIT_QUICKSTART.md
   └── Deep dive: HOMEKIT_INTEGRATION.md

2. CONFIGURE PROJECT
   ├── Add Resources/App.entitlements to Xcode
   ├── Add Resources/Info.plist to Xcode
   └── Enable HomeKit capability in Xcode

3. IMPLEMENT MANAGERS
   ├── Create Sources/HomeKit/HomeKitManager.swift
   ├── Create Sources/HomeKit/AccessoryManager.swift
   ├── Create Sources/HomeKit/TriggerManager.swift
   └── Create Sources/HomeKit/HomeManager.swift

4. TRY EXAMPLES
   ├── Run Examples/BasicHomeKitSetup.swift
   ├── Run Examples/AccessoryControl.swift
   └── Run Examples/AutomationTriggers.swift

5. INTEGRATE
   ├── Create ScreenshotHomeKitIntegration.swift
   ├── Connect to existing ScreenshotCapture
   └── Test complete workflow

6. TEST & DEPLOY
   ├── Run Tests/HomeKitTests/
   ├── Test on physical device
   └── Deploy to users
```

## Key Dependencies

### Apple Frameworks Required
```swift
import HomeKit        // Core HomeKit functionality
import Foundation     // Basic Swift functionality
import AppKit         // macOS UI (for screenshots)
import Combine        // Reactive programming (optional)
```

### Package.swift Targets

```swift
.target(name: "HomeKit", dependencies: [])
.target(name: "Screenshot", dependencies: [])
.target(name: "App", dependencies: ["Screenshot", "HomeKit"])
.testTarget(name: "HomeKitTests", dependencies: ["HomeKit"])
```

## Configuration Files Priority

### Must Have (Won't work without these)
1. ✅ `Resources/App.entitlements` - HomeKit entitlement
2. ✅ `Resources/Info.plist` - Usage descriptions

### Should Have (Best practices)
3. ✅ `HOMEKIT_INTEGRATION.md` - Documentation
4. ✅ `Examples/BasicHomeKitSetup.swift` - Working example

### Nice to Have (Reference & testing)
5. ⭐ `HOMEKIT_QUICKSTART.md` - Quick reference
6. ⭐ `Examples/AccessoryControl.swift` - More examples
7. ⭐ `Tests/HomeKitTests/` - Unit tests
8. ⭐ `Resources/HomeKitAccessories/accessories.json` - Config reference

## Quick Command Reference

```bash
# Navigate to project
cd /path/to/screenshot-auto-renamer

# View structure
tree -L 3 -I 'builds|.git'

# Read main documentation
cat HOMEKIT_INTEGRATION.md | less

# Read quick start
cat HOMEKIT_QUICKSTART.md | less

# Build project
swift build

# Run example
swift run

# Run tests
swift test

# View example files
ls -la Examples/
cat Examples/BasicHomeKitSetup.swift
```

## Next Steps

1. **Read**: Start with `HOMEKIT_QUICKSTART.md`
2. **Understand**: Read `HOMEKIT_INTEGRATION.md` thoroughly
3. **Configure**: Set up entitlements and Info.plist in Xcode
4. **Implement**: Create the manager classes in `Sources/HomeKit/`
5. **Test**: Try the examples and run tests
6. **Integrate**: Connect HomeKit to screenshot functionality

---

**All documentation and examples have been created!**

For questions, refer to `HOMEKIT_INTEGRATION.md` sections:
- Requirements → Section "Requirements"
- Project Structure → Section "Typical Project Structure"
- Code Examples → Section "Core Components"
- Common Issues → Section "Common Issues and Solutions"

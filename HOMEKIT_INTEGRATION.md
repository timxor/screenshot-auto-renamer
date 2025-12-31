# HomeKit Integration Guide

This document outlines what is required for HomeKit integration in a macOS/iOS application.

## Overview

HomeKit is Apple's framework for home automation, allowing apps to communicate with and control smart home accessories. For a screenshot auto-renamer utility, HomeKit integration could enable automation triggers or smart home integrations.

## Requirements

### 1. Development Prerequisites

- **Apple Developer Account**: Required for HomeKit entitlements
- **macOS 10.15+** or **iOS 13.0+**: Minimum OS versions
- **Xcode 11+**: IDE with HomeKit framework support
- **Swift 5.0+**: Programming language
- **Physical iOS device**: HomeKit testing requires actual hardware (simulator has limitations)

### 2. Frameworks and Dependencies

```swift
import HomeKit
import Foundation
```

Optional but commonly used:
```swift
import Combine      // For reactive programming
import SwiftUI      // For modern UI (iOS/macOS)
import AppKit       // For macOS specific features
```

### 3. Capabilities and Entitlements

#### Required Entitlements File: `App.entitlements`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.homekit</key>
    <true/>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
</plist>
```

### 4. Info.plist Configuration

```xml
<key>NSHomeKitUsageDescription</key>
<string>This app needs access to HomeKit to automate screenshot renaming based on home automation triggers.</string>
```

## Typical Project Structure

```
screenshot-auto-renamer/
├── Package.swift                          # Swift Package Manager configuration
├── README.md
├── HOMEKIT_INTEGRATION.md                # This file
├── Sources/
│   ├── App/
│   │   ├── main.swift                    # Application entry point
│   │   └── App.entitlements              # Entitlements file
│   ├── Screenshot/
│   │   └── ScreenshotCapture.swift       # Screenshot functionality
│   └── HomeKit/
│       ├── HomeKitManager.swift          # Main HomeKit manager
│       ├── AccessoryManager.swift        # Accessory discovery and management
│       ├── HomeManager.swift             # Home and room management
│       ├── TriggerManager.swift          # Automation triggers
│       └── Models/
│           ├── HomeKitAccessory.swift    # Accessory models
│           ├── HomeKitAction.swift       # Action models
│           └── HomeKitTrigger.swift      # Trigger models
├── Resources/
│   ├── Info.plist                        # App information
│   └── HomeKitAccessories/
│       └── accessories.json              # Accessory configurations
├── Tests/
│   ├── HomeKitTests/
│   │   ├── HomeKitManagerTests.swift
│   │   └── AccessoryManagerTests.swift
│   └── ScreenshotTests/
│       └── ScreenshotCaptureTests.swift
└── Examples/
    ├── BasicHomeKitSetup.swift           # Basic setup example
    ├── AccessoryControl.swift            # Accessory control example
    └── AutomationTriggers.swift          # Automation example
```

## Core Components

### 1. HomeKit Manager

The central manager handles HomeKit home manager lifecycle and delegates.

**File: `Sources/HomeKit/HomeKitManager.swift`**

```swift
import Foundation
import HomeKit

public class HomeKitManager: NSObject, ObservableObject {
    // Singleton instance
    public static let shared = HomeKitManager()
    
    // HomeKit home manager
    private var homeManager: HMHomeManager?
    
    // Published properties for SwiftUI
    @Published public var homes: [HMHome] = []
    @Published public var primaryHome: HMHome?
    @Published public var isAuthorized: Bool = false
    
    private override init() {
        super.init()
        setupHomeManager()
    }
    
    private func setupHomeManager() {
        homeManager = HMHomeManager()
        homeManager?.delegate = self
    }
    
    // Request HomeKit authorization
    public func requestAuthorization() {
        // HomeKit authorization is implicit when HMHomeManager is initialized
        // Check status through delegate methods
    }
    
    // Get all accessories in primary home
    public func getAllAccessories() -> [HMAccessory] {
        return primaryHome?.accessories ?? []
    }
    
    // Get accessories by room
    public func getAccessories(in room: HMRoom) -> [HMAccessory] {
        return room.accessories
    }
}

// MARK: - HMHomeManagerDelegate
extension HomeKitManager: HMHomeManagerDelegate {
    public func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        DispatchQueue.main.async { [weak self] in
            self?.homes = manager.homes
            self?.primaryHome = manager.primaryHome
            self?.isAuthorized = true
        }
    }
    
    public func homeManagerDidUpdatePrimaryHome(_ manager: HMHomeManager) {
        DispatchQueue.main.async { [weak self] in
            self?.primaryHome = manager.primaryHome
        }
    }
}
```

### 2. Accessory Manager

Manages HomeKit accessory discovery, pairing, and control.

**File: `Sources/HomeKit/AccessoryManager.swift`**

```swift
import Foundation
import HomeKit

public class AccessoryManager: NSObject {
    private let homeManager: HomeKitManager
    private var accessoryBrowser: HMAccessoryBrowser?
    
    // Discovered accessories
    @Published public var discoveredAccessories: [HMAccessory] = []
    
    public init(homeManager: HomeKitManager = .shared) {
        self.homeManager = homeManager
        super.init()
    }
    
    // Start discovering accessories
    public func startDiscovering() {
        accessoryBrowser = HMAccessoryBrowser()
        accessoryBrowser?.delegate = self
        accessoryBrowser?.startSearchingForNewAccessories()
    }
    
    // Stop discovering
    public func stopDiscovering() {
        accessoryBrowser?.stopSearchingForNewAccessories()
    }
    
    // Add accessory to home
    public func addAccessory(_ accessory: HMAccessory, to home: HMHome, completion: @escaping (Error?) -> Void) {
        home.addAccessory(accessory) { error in
            completion(error)
        }
    }
    
    // Control accessory characteristic
    public func controlAccessory(
        _ accessory: HMAccessory,
        service: HMService,
        characteristic: HMCharacteristic,
        value: Any,
        completion: @escaping (Error?) -> Void
    ) {
        characteristic.writeValue(value) { error in
            completion(error)
        }
    }
    
    // Read accessory characteristic
    public func readCharacteristic(
        _ characteristic: HMCharacteristic,
        completion: @escaping (Any?, Error?) -> Void
    ) {
        characteristic.readValue { error in
            completion(characteristic.value, error)
        }
    }
}

// MARK: - HMAccessoryBrowserDelegate
extension AccessoryManager: HMAccessoryBrowserDelegate {
    public func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        DispatchQueue.main.async { [weak self] in
            self?.discoveredAccessories.append(accessory)
        }
    }
    
    public func accessoryBrowser(_ browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory) {
        DispatchQueue.main.async { [weak self] in
            self?.discoveredAccessories.removeAll { $0.uniqueIdentifier == accessory.uniqueIdentifier }
        }
    }
}
```

### 3. Trigger Manager

Handles HomeKit automation triggers.

**File: `Sources/HomeKit/TriggerManager.swift`**

```swift
import Foundation
import HomeKit

public class TriggerManager {
    private let homeManager: HomeKitManager
    
    public init(homeManager: HomeKitManager = .shared) {
        self.homeManager = homeManager
    }
    
    // Create time-based trigger
    public func createTimeTrigger(
        name: String,
        fireDate: DateComponents,
        recurrence: DateComponents? = nil,
        home: HMHome,
        actions: [HMCharacteristicWriteAction<NSCopying>],
        completion: @escaping (HMTimerTrigger?, Error?) -> Void
    ) {
        let trigger = HMTimerTrigger(
            name: name,
            fireDate: fireDate,
            timeZone: nil,
            recurrence: recurrence,
            recurrenceCalendar: nil
        )
        
        home.addTrigger(trigger) { error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            // Add actions to trigger
            trigger.addActionSet(HMActionSet()) { error in
                completion(trigger, error)
            }
        }
    }
    
    // Create event trigger (e.g., when someone arrives home)
    public func createEventTrigger(
        name: String,
        events: [HMEvent],
        home: HMHome,
        completion: @escaping (HMEventTrigger?, Error?) -> Void
    ) {
        let trigger = HMEventTrigger(
            name: name,
            events: events,
            predicate: nil
        )
        
        home.addTrigger(trigger) { error in
            completion(error == nil ? trigger : nil, error)
        }
    }
    
    // Create characteristic trigger
    public func createCharacteristicTrigger(
        name: String,
        characteristic: HMCharacteristic,
        triggerValue: NSCopying & NSObjectProtocol,
        home: HMHome,
        completion: @escaping (Error?) -> Void
    ) {
        let event = HMCharacteristicEvent(
            characteristic: characteristic,
            triggerValue: triggerValue
        )
        
        let trigger = HMEventTrigger(
            name: name,
            events: [event],
            predicate: nil
        )
        
        home.addTrigger(trigger, completionHandler: completion)
    }
}
```

### 4. Home Manager

Manages homes and rooms.

**File: `Sources/HomeKit/HomeManager.swift`**

```swift
import Foundation
import HomeKit

public class HomeManager {
    private let homeKitManager: HomeKitManager
    
    public init(homeKitManager: HomeKitManager = .shared) {
        self.homeKitManager = homeKitManager
    }
    
    // Create a new home
    public func createHome(name: String, completion: @escaping (HMHome?, Error?) -> Void) {
        homeKitManager.homeManager?.addHome(withName: name, completionHandler: completion)
    }
    
    // Remove a home
    public func removeHome(_ home: HMHome, completion: @escaping (Error?) -> Void) {
        homeKitManager.homeManager?.removeHome(home, completionHandler: completion)
    }
    
    // Create a room in home
    public func createRoom(name: String, in home: HMHome, completion: @escaping (HMRoom?, Error?) -> Void) {
        home.addRoom(withName: name, completionHandler: completion)
    }
    
    // Remove a room
    public func removeRoom(_ room: HMRoom, from home: HMHome, completion: @escaping (Error?) -> Void) {
        home.removeRoom(room, completionHandler: completion)
    }
    
    // Assign accessory to room
    public func assignAccessory(_ accessory: HMAccessory, to room: HMRoom, completion: @escaping (Error?) -> Void) {
        accessory.room?.home?.assignAccessory(accessory, to: room, completionHandler: completion)
    }
}
```

## Common HomeKit Characteristics

### Service Types
- **HMServiceTypeLightbulb**: Light control
- **HMServiceTypeSwitch**: Switch control
- **HMServiceTypeThermostat**: Temperature control
- **HMServiceTypeLockMechanism**: Lock control
- **HMServiceTypeGarageDoorOpener**: Garage door control
- **HMServiceTypeSensor**: Various sensors

### Characteristic Types
- **HMCharacteristicTypePowerState**: On/Off state
- **HMCharacteristicTypeBrightness**: Light brightness (0-100)
- **HMCharacteristicTypeHue**: Color hue (0-360)
- **HMCharacteristicTypeSaturation**: Color saturation (0-100)
- **HMCharacteristicTypeCurrentTemperature**: Temperature reading
- **HMCharacteristicTypeTargetTemperature**: Target temperature
- **HMCharacteristicTypeLockState**: Lock status

## Integration with Screenshot Auto-Renamer

Here's how you might integrate HomeKit with the screenshot functionality:

**File: `Sources/HomeKit/ScreenshotHomeKitIntegration.swift`**

```swift
import Foundation
import HomeKit

public class ScreenshotHomeKitIntegration {
    private let homeKitManager = HomeKitManager.shared
    private let accessoryManager = AccessoryManager()
    
    // Trigger screenshot based on HomeKit event
    public func setupScreenshotTrigger() {
        guard let home = homeKitManager.primaryHome else {
            print("No primary home found")
            return
        }
        
        // Example: Take screenshot when a specific light turns on
        if let lightAccessory = home.accessories.first(where: { 
            $0.services.contains(where: { $0.serviceType == HMServiceTypeLightbulb })
        }) {
            monitorAccessory(lightAccessory)
        }
    }
    
    private func monitorAccessory(_ accessory: HMAccessory) {
        // Find power state characteristic
        guard let service = accessory.services.first(where: { $0.serviceType == HMServiceTypeLightbulb }),
              let characteristic = service.characteristics.first(where: { 
                  $0.characteristicType == HMCharacteristicTypePowerState 
              }) else {
            return
        }
        
        // Enable notifications
        characteristic.enableNotification(true) { error in
            if let error = error {
                print("Failed to enable notifications: \(error)")
            }
        }
    }
    
    // Get current room name for screenshot naming
    public func getCurrentRoomName() -> String? {
        guard let home = homeKitManager.primaryHome else { return nil }
        
        // Find accessories that are "on" or active
        for accessory in home.accessories {
            for service in accessory.services {
                for characteristic in service.characteristics {
                    if characteristic.characteristicType == HMCharacteristicTypePowerState,
                       let value = characteristic.value as? Bool,
                       value == true {
                        return accessory.room?.name
                    }
                }
            }
        }
        return nil
    }
}
```

## Example: Basic Setup

**File: `Examples/BasicHomeKitSetup.swift`**

```swift
import Foundation
import HomeKit

func basicHomeKitSetup() {
    let homeKitManager = HomeKitManager.shared
    
    // Wait for HomeKit to initialize
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        if let home = homeKitManager.primaryHome {
            print("Primary home: \(home.name)")
            print("Rooms: \(home.rooms.map { $0.name })")
            print("Accessories: \(home.accessories.map { $0.name })")
            
            // List all characteristics
            for accessory in home.accessories {
                print("\nAccessory: \(accessory.name)")
                for service in accessory.services {
                    print("  Service: \(service.serviceType)")
                    for characteristic in service.characteristics {
                        print("    Characteristic: \(characteristic.characteristicType)")
                        if let value = characteristic.value {
                            print("      Value: \(value)")
                        }
                    }
                }
            }
        } else {
            print("No primary home configured")
        }
    }
}
```

## Package.swift Configuration

Update your `Package.swift` to include HomeKit module:

```swift
// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "screenshot-auto-renamer",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .executable(
            name: "screenshot-auto-renamer",
            targets: ["App"]
        )
    ],
    dependencies: [
        // Add HomeKit-related dependencies if needed
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: ["Screenshot", "HomeKit"]
        ),
        .target(
            name: "Screenshot",
            dependencies: []
        ),
        .target(
            name: "HomeKit",
            dependencies: []
        ),
        .testTarget(
            name: "HomeKitTests",
            dependencies: ["HomeKit"]
        )
    ]
)
```

## Testing

HomeKit testing requires:
1. **Physical Device**: Use actual iOS device (simulator has limitations)
2. **Home App**: Set up at least one home in the Home app
3. **Accessories**: Physical or simulated HomeKit accessories
4. **Same Network**: Device must be on same network as accessories

### Unit Testing Example

**File: `Tests/HomeKitTests/HomeKitManagerTests.swift`**

```swift
import XCTest
@testable import HomeKit

final class HomeKitManagerTests: XCTestCase {
    var sut: HomeKitManager!
    
    override func setUp() {
        super.setUp()
        sut = HomeKitManager.shared
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testHomeKitManagerInitialization() {
        XCTAssertNotNil(sut)
    }
    
    func testGetAllAccessories() {
        // This requires actual HomeKit setup
        let accessories = sut.getAllAccessories()
        XCTAssertNotNil(accessories)
    }
}
```

## Security Considerations

1. **Entitlements**: Ensure HomeKit entitlement is properly configured
2. **Privacy**: Request permission and explain usage clearly
3. **Secure Communication**: HomeKit uses encrypted communication by default
4. **User Consent**: Always get explicit user consent for automation
5. **Data Storage**: Don't store HomeKit credentials or sensitive data

## Common Issues and Solutions

### Issue 1: "HomeKit not authorized"
**Solution**: Ensure `NSHomeKitUsageDescription` is in Info.plist

### Issue 2: "No accessories found"
**Solution**: Verify accessories are set up in Home app and on same network

### Issue 3: "Simulator not working"
**Solution**: Use physical iOS device for HomeKit development

### Issue 4: "Characteristic write failed"
**Solution**: Check characteristic permissions and value types

## Resources

- [Apple HomeKit Documentation](https://developer.apple.com/documentation/homekit)
- [HomeKit Accessory Protocol Specification](https://developer.apple.com/homekit/)
- [HomeKit Best Practices](https://developer.apple.com/design/human-interface-guidelines/homekit)
- [WWDC HomeKit Sessions](https://developer.apple.com/videos/homekit)

## Next Steps

1. Apply for HomeKit Commercial entitlement if publishing to App Store
2. Implement proper error handling and user feedback
3. Add UI for HomeKit configuration
4. Test with various HomeKit accessories
5. Implement automation scenarios specific to screenshot workflow
6. Add HomeKit Scene support for complex automations

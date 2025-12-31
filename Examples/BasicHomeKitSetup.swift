import Foundation
import HomeKit

/// Basic HomeKit setup example demonstrating initial configuration
func basicHomeKitSetup() {
    print("=== Basic HomeKit Setup Example ===\n")
    
    let homeKitManager = HomeKitManager.shared
    
    // Wait for HomeKit to initialize (HomeKit manager delegate methods are async)
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        if let home = homeKitManager.primaryHome {
            print("✅ Primary home found: \(home.name)")
            print("\n📍 Rooms (\(home.rooms.count)):")
            for room in home.rooms {
                print("  - \(room.name)")
            }
            
            print("\n🔌 Accessories (\(home.accessories.count)):")
            for accessory in home.accessories {
                print("\n  Accessory: \(accessory.name)")
                print("  Category: \(accessory.category.categoryType)")
                print("  Manufacturer: \(accessory.manufacturer ?? "Unknown")")
                print("  Model: \(accessory.model ?? "Unknown")")
                print("  Room: \(accessory.room?.name ?? "No room assigned")")
                
                // List services
                print("  Services:")
                for service in accessory.services {
                    print("    - \(service.name ?? "Unnamed") (\(service.serviceType))")
                    
                    // List characteristics
                    print("      Characteristics:")
                    for characteristic in service.characteristics {
                        let readable = characteristic.properties.contains(.readable)
                        let writable = characteristic.properties.contains(.writable)
                        let permissions = readable && writable ? "R/W" : readable ? "R" : writable ? "W" : "-"
                        
                        var valueStr = "N/A"
                        if let value = characteristic.value {
                            valueStr = "\(value)"
                        }
                        
                        print("        • \(characteristic.characteristicType) [\(permissions)]: \(valueStr)")
                    }
                }
            }
            
            print("\n🎬 Action Sets (\(home.actionSets.count)):")
            for actionSet in home.actionSets {
                print("  - \(actionSet.name)")
            }
            
            print("\n⏰ Triggers (\(home.triggers.count)):")
            for trigger in home.triggers {
                print("  - \(trigger.name)")
            }
            
        } else {
            print("❌ No primary home configured")
            print("\nTo set up HomeKit:")
            print("1. Open the Home app on your iOS device")
            print("2. Create a home or select existing home")
            print("3. Add accessories to your home")
            print("4. Run this app again")
        }
    }
    
    // Keep the run loop alive to receive async callbacks
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
}

/// Example: Check HomeKit authorization status
func checkHomeKitAuthorization() {
    let manager = HomeKitManager.shared
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        if manager.isAuthorized {
            print("✅ HomeKit is authorized")
            print("Homes available: \(manager.homes.count)")
        } else {
            print("⚠️  HomeKit authorization pending or denied")
            print("Please check:")
            print("1. Info.plist contains NSHomeKitUsageDescription")
            print("2. App has HomeKit entitlement")
            print("3. User has granted HomeKit permission")
        }
    }
    
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 3))
}

// Uncomment to run examples
// basicHomeKitSetup()
// checkHomeKitAuthorization()

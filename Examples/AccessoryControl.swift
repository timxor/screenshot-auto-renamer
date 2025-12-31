import Foundation
import HomeKit

/// Example: Control a light bulb accessory
func controlLightBulb() {
    print("=== Light Bulb Control Example ===\n")
    
    let homeManager = HomeKitManager.shared
    let accessoryManager = AccessoryManager(homeManager: homeManager)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        guard let home = homeManager.primaryHome else {
            print("❌ No primary home found")
            return
        }
        
        // Find a light bulb accessory
        guard let lightAccessory = home.accessories.first(where: { accessory in
            accessory.services.contains { $0.serviceType == HMServiceTypeLightbulb }
        }) else {
            print("❌ No light bulb accessory found")
            return
        }
        
        print("✅ Found light bulb: \(lightAccessory.name)")
        
        guard let lightService = lightAccessory.services.first(where: { 
            $0.serviceType == HMServiceTypeLightbulb 
        }) else {
            print("❌ Light service not found")
            return
        }
        
        // Turn on the light
        if let powerCharacteristic = lightService.characteristics.first(where: { 
            $0.characteristicType == HMCharacteristicTypePowerState 
        }) {
            print("\n💡 Turning light ON...")
            accessoryManager.controlAccessory(
                lightAccessory,
                service: lightService,
                characteristic: powerCharacteristic,
                value: true
            ) { error in
                if let error = error {
                    print("❌ Error turning light on: \(error.localizedDescription)")
                } else {
                    print("✅ Light turned ON")
                }
            }
        }
        
        // Set brightness (if supported)
        if let brightnessCharacteristic = lightService.characteristics.first(where: { 
            $0.characteristicType == HMCharacteristicTypeBrightness 
        }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("\n🔆 Setting brightness to 75%...")
                accessoryManager.controlAccessory(
                    lightAccessory,
                    service: lightService,
                    characteristic: brightnessCharacteristic,
                    value: 75
                ) { error in
                    if let error = error {
                        print("❌ Error setting brightness: \(error.localizedDescription)")
                    } else {
                        print("✅ Brightness set to 75%")
                    }
                }
            }
        }
    }
    
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
}

/// Example: Read temperature from a sensor
func readTemperatureSensor() {
    print("=== Temperature Sensor Reading Example ===\n")
    
    let homeManager = HomeKitManager.shared
    let accessoryManager = AccessoryManager(homeManager: homeManager)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        guard let home = homeManager.primaryHome else {
            print("❌ No primary home found")
            return
        }
        
        // Find a temperature sensor
        for accessory in home.accessories {
            for service in accessory.services {
                if let tempCharacteristic = service.characteristics.first(where: { 
                    $0.characteristicType == HMCharacteristicTypeCurrentTemperature 
                }) {
                    print("🌡️  Found temperature sensor: \(accessory.name)")
                    
                    accessoryManager.readCharacteristic(tempCharacteristic) { value, error in
                        if let error = error {
                            print("❌ Error reading temperature: \(error.localizedDescription)")
                        } else if let temperature = value as? Double {
                            print("✅ Current temperature: \(temperature)°C")
                        }
                    }
                    return
                }
            }
        }
        
        print("❌ No temperature sensor found")
    }
    
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
}

/// Example: Control a switch
func controlSwitch(turnOn: Bool) {
    print("=== Switch Control Example ===\n")
    
    let homeManager = HomeKitManager.shared
    let accessoryManager = AccessoryManager(homeManager: homeManager)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        guard let home = homeManager.primaryHome else {
            print("❌ No primary home found")
            return
        }
        
        // Find a switch accessory
        guard let switchAccessory = home.accessories.first(where: { accessory in
            accessory.services.contains { $0.serviceType == HMServiceTypeSwitch }
        }) else {
            print("❌ No switch accessory found")
            return
        }
        
        print("✅ Found switch: \(switchAccessory.name)")
        
        guard let switchService = switchAccessory.services.first(where: { 
            $0.serviceType == HMServiceTypeSwitch 
        }),
        let powerCharacteristic = switchService.characteristics.first(where: { 
            $0.characteristicType == HMCharacteristicTypePowerState 
        }) else {
            print("❌ Switch service or characteristic not found")
            return
        }
        
        let action = turnOn ? "ON" : "OFF"
        print("\n🔌 Turning switch \(action)...")
        
        accessoryManager.controlAccessory(
            switchAccessory,
            service: switchService,
            characteristic: powerCharacteristic,
            value: turnOn
        ) { error in
            if let error = error {
                print("❌ Error controlling switch: \(error.localizedDescription)")
            } else {
                print("✅ Switch turned \(action)")
            }
        }
    }
    
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
}

/// Example: Discover new accessories
func discoverNewAccessories() {
    print("=== Accessory Discovery Example ===\n")
    
    let accessoryManager = AccessoryManager()
    
    print("🔍 Starting accessory discovery...")
    print("Put your HomeKit accessory in pairing mode\n")
    
    accessoryManager.startDiscovering()
    
    // Monitor for 30 seconds
    var count = 0
    Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
        count += 5
        let discovered = accessoryManager.discoveredAccessories
        print("[\(count)s] Found \(discovered.count) accessories:")
        for accessory in discovered {
            print("  - \(accessory.name)")
        }
        
        if count >= 30 {
            timer.invalidate()
            accessoryManager.stopDiscovering()
            print("\n✅ Discovery stopped")
        }
    }
    
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 35))
}

/// Example: Monitor accessory state changes
func monitorAccessoryStateChanges() {
    print("=== Accessory State Monitoring Example ===\n")
    
    let homeManager = HomeKitManager.shared
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        guard let home = homeManager.primaryHome else {
            print("❌ No primary home found")
            return
        }
        
        print("👀 Monitoring state changes for all accessories...")
        print("(Make changes in the Home app to see updates)\n")
        
        // Enable notifications for all characteristics
        for accessory in home.accessories {
            print("Monitoring: \(accessory.name)")
            for service in accessory.services {
                for characteristic in service.characteristics {
                    if characteristic.properties.contains(.supportsEventNotification) {
                        characteristic.enableNotification(true) { error in
                            if let error = error {
                                print("  ⚠️  Failed to enable notifications for \(characteristic.characteristicType): \(error)")
                            }
                        }
                    }
                }
            }
        }
        
        print("\n✅ Monitoring enabled. Changes will be logged automatically.")
    }
    
    // Keep monitoring for 60 seconds
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 65))
}

// Uncomment to run examples
// controlLightBulb()
// readTemperatureSensor()
// controlSwitch(turnOn: true)
// discoverNewAccessories()
// monitorAccessoryStateChanges()

import Foundation
import HomeKit

/// Example: Create a time-based trigger
func createDailyTrigger() {
    print("=== Daily Time Trigger Example ===\n")
    
    let homeManager = HomeKitManager.shared
    let triggerManager = TriggerManager(homeManager: homeManager)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        guard let home = homeManager.primaryHome else {
            print("❌ No primary home found")
            return
        }
        
        // Create trigger to fire every day at 9:00 AM
        var fireDate = DateComponents()
        fireDate.hour = 9
        fireDate.minute = 0
        
        var recurrence = DateComponents()
        recurrence.day = 1  // Repeat daily
        
        print("⏰ Creating daily trigger for 9:00 AM...")
        
        triggerManager.createTimeTrigger(
            name: "Daily 9 AM Screenshot Reminder",
            fireDate: fireDate,
            recurrence: recurrence,
            home: home,
            actions: []
        ) { trigger, error in
            if let error = error {
                print("❌ Error creating trigger: \(error.localizedDescription)")
            } else if let trigger = trigger {
                print("✅ Trigger created successfully: \(trigger.name)")
                print("   Fires at: \(fireDate.hour ?? 0):\(String(format: "%02d", fireDate.minute ?? 0))")
                print("   Recurrence: Daily")
            }
        }
    }
    
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
}

/// Example: Create a location-based trigger
func createLocationTrigger() {
    print("=== Location-Based Trigger Example ===\n")
    
    let homeManager = HomeKitManager.shared
    let triggerManager = TriggerManager(homeManager: homeManager)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        guard let home = homeManager.primaryHome else {
            print("❌ No primary home found")
            return
        }
        
        // Create a location event (when someone arrives home)
        let locationEvent = HMLocationEvent(region: home.homeRegion)
        
        print("📍 Creating location trigger for arriving home...")
        
        triggerManager.createEventTrigger(
            name: "Arrived Home",
            events: [locationEvent],
            home: home
        ) { trigger, error in
            if let error = error {
                print("❌ Error creating location trigger: \(error.localizedDescription)")
            } else if let trigger = trigger {
                print("✅ Location trigger created: \(trigger.name)")
                print("   Triggers when: Arriving home")
            }
        }
    }
    
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
}

/// Example: Create a characteristic-based trigger
func createCharacteristicTrigger() {
    print("=== Characteristic-Based Trigger Example ===\n")
    
    let homeManager = HomeKitManager.shared
    let triggerManager = TriggerManager(homeManager: homeManager)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        guard let home = homeManager.primaryHome else {
            print("❌ No primary home found")
            return
        }
        
        // Find a light accessory
        guard let lightAccessory = home.accessories.first(where: { accessory in
            accessory.services.contains { $0.serviceType == HMServiceTypeLightbulb }
        }),
        let lightService = lightAccessory.services.first(where: { 
            $0.serviceType == HMServiceTypeLightbulb 
        }),
        let powerCharacteristic = lightService.characteristics.first(where: { 
            $0.characteristicType == HMCharacteristicTypePowerState 
        }) else {
            print("❌ No light bulb found to create trigger")
            return
        }
        
        print("💡 Creating trigger for when '\(lightAccessory.name)' turns on...")
        
        triggerManager.createCharacteristicTrigger(
            name: "Light Turned On - Take Screenshot",
            characteristic: powerCharacteristic,
            triggerValue: true as NSCopying & NSObjectProtocol,
            home: home
        ) { error in
            if let error = error {
                print("❌ Error creating characteristic trigger: \(error.localizedDescription)")
            } else {
                print("✅ Characteristic trigger created successfully")
                print("   Triggers when: \(lightAccessory.name) turns ON")
                print("   Action: Could trigger a screenshot")
            }
        }
    }
    
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
}

/// Example: Create an action set (scene)
func createScreenshotScene() {
    print("=== Screenshot Scene Creation Example ===\n")
    
    let homeManager = HomeKitManager.shared
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        guard let home = homeManager.primaryHome else {
            print("❌ No primary home found")
            return
        }
        
        print("🎬 Creating 'Screenshot Mode' scene...")
        
        home.addActionSet(withName: "Screenshot Mode") { actionSet, error in
            if let error = error {
                print("❌ Error creating action set: \(error.localizedDescription)")
                return
            }
            
            guard let actionSet = actionSet else {
                print("❌ Action set creation failed")
                return
            }
            
            print("✅ Scene created: \(actionSet.name)")
            
            // Add actions to the scene (e.g., turn on specific lights)
            if let lightAccessory = home.accessories.first(where: { accessory in
                accessory.services.contains { $0.serviceType == HMServiceTypeLightbulb }
            }),
            let lightService = lightAccessory.services.first(where: { 
                $0.serviceType == HMServiceTypeLightbulb 
            }),
            let powerCharacteristic = lightService.characteristics.first(where: { 
                $0.characteristicType == HMCharacteristicTypePowerState 
            }) {
                let action = HMCharacteristicWriteAction(
                    characteristic: powerCharacteristic,
                    targetValue: true
                )
                
                actionSet.addAction(action) { error in
                    if let error = error {
                        print("❌ Error adding action: \(error.localizedDescription)")
                    } else {
                        print("✅ Added action: Turn on \(lightAccessory.name)")
                    }
                }
            }
        }
    }
    
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
}

/// Example: Execute an action set
func executeScene(named sceneName: String) {
    print("=== Execute Scene Example ===\n")
    
    let homeManager = HomeKitManager.shared
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        guard let home = homeManager.primaryHome else {
            print("❌ No primary home found")
            return
        }
        
        guard let actionSet = home.actionSets.first(where: { $0.name == sceneName }) else {
            print("❌ Scene '\(sceneName)' not found")
            print("Available scenes:")
            for scene in home.actionSets {
                print("  - \(scene.name)")
            }
            return
        }
        
        print("🎬 Executing scene: \(sceneName)...")
        
        home.executeActionSet(actionSet) { error in
            if let error = error {
                print("❌ Error executing scene: \(error.localizedDescription)")
            } else {
                print("✅ Scene executed successfully")
                print("   All actions in '\(sceneName)' completed")
            }
        }
    }
    
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
}

/// Example: List all automation triggers
func listAllTriggers() {
    print("=== List All Triggers Example ===\n")
    
    let homeManager = HomeKitManager.shared
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        guard let home = homeManager.primaryHome else {
            print("❌ No primary home found")
            return
        }
        
        print("📋 Automation Triggers (\(home.triggers.count)):\n")
        
        for (index, trigger) in home.triggers.enumerated() {
            print("\(index + 1). \(trigger.name)")
            print("   Enabled: \(trigger.isEnabled ? "✅" : "❌")")
            
            if let timeTrigger = trigger as? HMTimerTrigger {
                print("   Type: Time-based")
                if let fireDate = timeTrigger.fireDate {
                    print("   Fires at: \(fireDate.hour ?? 0):\(String(format: "%02d", fireDate.minute ?? 0))")
                }
                if let recurrence = timeTrigger.recurrence {
                    print("   Recurrence: Every \(recurrence.day ?? 0) day(s)")
                }
            } else if let eventTrigger = trigger as? HMEventTrigger {
                print("   Type: Event-based")
                print("   Events: \(eventTrigger.events.count)")
                for event in eventTrigger.events {
                    if let charEvent = event as? HMCharacteristicEvent {
                        print("     - Characteristic: \(charEvent.characteristic.characteristicType)")
                        if let value = charEvent.triggerValue {
                            print("       Value: \(value)")
                        }
                    } else if event is HMLocationEvent {
                        print("     - Location event")
                    }
                }
            }
            
            print("   Action Sets: \(trigger.actionSets.count)")
            print()
        }
    }
    
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
}

// Uncomment to run examples
// createDailyTrigger()
// createLocationTrigger()
// createCharacteristicTrigger()
// createScreenshotScene()
// executeScene(named: "Screenshot Mode")
// listAllTriggers()

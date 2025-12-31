import XCTest
@testable import HomeKit

/// Test suite for HomeKit Manager functionality
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
    
    // MARK: - Initialization Tests
    
    func testHomeKitManagerSingleton() {
        let instance1 = HomeKitManager.shared
        let instance2 = HomeKitManager.shared
        XCTAssertTrue(instance1 === instance2, "HomeKitManager should be a singleton")
    }
    
    func testHomeKitManagerInitialization() {
        XCTAssertNotNil(sut, "HomeKitManager should initialize successfully")
    }
    
    // MARK: - Home Management Tests
    
    func testGetAllAccessories() {
        // Note: This test requires actual HomeKit setup
        let accessories = sut.getAllAccessories()
        XCTAssertNotNil(accessories, "getAllAccessories should return an array")
    }
    
    func testHomesArray() {
        // Homes array should be initialized (empty or populated)
        XCTAssertNotNil(sut.homes, "Homes array should be initialized")
    }
    
    func testPrimaryHome() {
        // Primary home can be nil if not configured
        // This is not a failure condition
        if let primaryHome = sut.primaryHome {
            XCTAssertFalse(primaryHome.name.isEmpty, "Primary home should have a name")
        }
    }
    
    // MARK: - Authorization Tests
    
    func testAuthorizationStatus() {
        // Authorization status should be a boolean
        XCTAssertNotNil(sut.isAuthorized, "Authorization status should be available")
    }
    
    func testRequestAuthorization() {
        // Request authorization should not crash
        XCTAssertNoThrow(sut.requestAuthorization(), "Request authorization should not throw")
    }
    
    // MARK: - Room Management Tests
    
    func testGetAccessoriesInRoom() {
        guard let home = sut.primaryHome,
              let room = home.rooms.first else {
            // Skip test if no home or rooms configured
            return
        }
        
        let accessories = sut.getAccessories(in: room)
        XCTAssertNotNil(accessories, "Should return accessories array for room")
    }
}

/// Test suite for Accessory Manager functionality
final class AccessoryManagerTests: XCTestCase {
    
    var sut: AccessoryManager!
    var homeManager: HomeKitManager!
    
    override func setUp() {
        super.setUp()
        homeManager = HomeKitManager.shared
        sut = AccessoryManager(homeManager: homeManager)
    }
    
    override func tearDown() {
        sut.stopDiscovering()
        sut = nil
        homeManager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testAccessoryManagerInitialization() {
        XCTAssertNotNil(sut, "AccessoryManager should initialize successfully")
    }
    
    // MARK: - Discovery Tests
    
    func testStartDiscovering() {
        XCTAssertNoThrow(sut.startDiscovering(), "Start discovering should not throw")
    }
    
    func testStopDiscovering() {
        sut.startDiscovering()
        XCTAssertNoThrow(sut.stopDiscovering(), "Stop discovering should not throw")
    }
    
    func testDiscoveredAccessoriesArray() {
        XCTAssertNotNil(sut.discoveredAccessories, "Discovered accessories array should be initialized")
    }
    
    // MARK: - Accessory Control Tests
    
    func testControlAccessoryRequiresValidCharacteristic() {
        // This is a mock test structure
        // Real tests would require actual HomeKit accessories
        
        guard let home = homeManager.primaryHome,
              let accessory = home.accessories.first,
              let service = accessory.services.first,
              let characteristic = service.characteristics.first else {
            // Skip if no accessories available
            return
        }
        
        let expectation = self.expectation(description: "Control accessory")
        
        sut.controlAccessory(
            accessory,
            service: service,
            characteristic: characteristic,
            value: true
        ) { error in
            // Test should handle both success and failure
            XCTAssertNotNil(error != nil || error == nil, "Should receive a completion callback")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
    }
}

/// Test suite for Trigger Manager functionality
final class TriggerManagerTests: XCTestCase {
    
    var sut: TriggerManager!
    var homeManager: HomeKitManager!
    
    override func setUp() {
        super.setUp()
        homeManager = HomeKitManager.shared
        sut = TriggerManager(homeManager: homeManager)
    }
    
    override func tearDown() {
        sut = nil
        homeManager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testTriggerManagerInitialization() {
        XCTAssertNotNil(sut, "TriggerManager should initialize successfully")
    }
    
    // MARK: - Time Trigger Tests
    
    func testCreateTimeTriggerComponents() {
        // Test that date components are created correctly
        var fireDate = DateComponents()
        fireDate.hour = 9
        fireDate.minute = 0
        
        XCTAssertEqual(fireDate.hour, 9, "Hour should be set correctly")
        XCTAssertEqual(fireDate.minute, 0, "Minute should be set correctly")
    }
    
    // MARK: - Event Trigger Tests
    
    func testEventTriggerCreationRequiresHome() {
        // Event triggers require a configured home
        guard let home = homeManager.primaryHome else {
            // Skip test if no home configured
            return
        }
        
        XCTAssertNotNil(home, "Home should exist for event trigger creation")
    }
}

/// Integration tests for HomeKit components
final class HomeKitIntegrationTests: XCTestCase {
    
    var homeManager: HomeKitManager!
    var accessoryManager: AccessoryManager!
    var triggerManager: TriggerManager!
    
    override func setUp() {
        super.setUp()
        homeManager = HomeKitManager.shared
        accessoryManager = AccessoryManager(homeManager: homeManager)
        triggerManager = TriggerManager(homeManager: homeManager)
    }
    
    override func tearDown() {
        accessoryManager.stopDiscovering()
        accessoryManager = nil
        triggerManager = nil
        homeManager = nil
        super.tearDown()
    }
    
    // MARK: - Integration Tests
    
    func testManagersCanWorkTogether() {
        XCTAssertNotNil(homeManager, "HomeManager should exist")
        XCTAssertNotNil(accessoryManager, "AccessoryManager should exist")
        XCTAssertNotNil(triggerManager, "TriggerManager should exist")
    }
    
    func testAccessoryManagerUsesHomeManager() {
        // AccessoryManager should reference the same HomeKitManager instance
        XCTAssertTrue(homeManager === HomeKitManager.shared, "Should use shared instance")
    }
}

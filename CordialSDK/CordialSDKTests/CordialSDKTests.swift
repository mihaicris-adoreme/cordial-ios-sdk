//
//  CordialSDKTests.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 3/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import XCTest
@testable import CordialSDK

class CordialSDKTests: XCTestCase {
    
    let cordialAPI = CordialAPI()
    let testCase = TestCase()
    
    let testDeviceToken = "ffa29a48a76025c0ff73a2cb2a6ad50266114c03b3f612e824d61be7c9a0f4cb"
    let testPrimaryKey = "test_primary_key@gmail.com"
    let testJWT = "testJWT"
    let testMcId = "test_mc_id"
    var testPushNotification = String()
    var testSilentNotification = String()
    var testSilentAndPushNotifications = String()
    let testDeepLinkURL = "https://tjs.cordialdev.com/prep-tj1.html"
    let testDeepLinkFallbackURL = "https://tjs.cordialdev.com/prep-tj2.html"
    
    override func setUp() {
        self.testCase.clearAllTestCaseData()
        
        CordialApiConfiguration.shared.initialize(accountKey: "qc-all-channels", channelKey: "push")
        CordialApiConfiguration.shared.osLogManager.setOSLogLevel(.none)
        CordialApiConfiguration.shared.qtyCachedEventQueue = 100
        CordialApiConfiguration.shared.eventsBulkSize = 1
        CordialApiConfiguration.shared.eventsBulkUploadInterval = 30
        CordialApiConfiguration.shared.pushNotificationDelegate = PushNotificationHandler()
        CordialApiConfiguration.shared.cordialDeepLinksDelegate = DeepLinksHandler()
        
        self.testPushNotification = """
            {
                "aps":{
                    "alert": "Text push notification message."
                },
                "deepLink": {
                    "url": "\(self.testDeepLinkURL)",
                    "fallbackUrl": "\(self.testDeepLinkFallbackURL)"
                },
                "mcID": "\(self.testMcId)"
            }
        """
        
        self.testSilentNotification = """
            {
                "aps":{
                    "content-available" : 1
                },
                "system": {
                    "iam": {
                        "type": "modal",
                        "displayType": "displayImmediately",
                        "inactiveSessionDisplay": "show-in-app"
                    }
                },
                "mcID": "\(self.testMcId)"
            }
        """
        
        self.testSilentAndPushNotifications = """
            {
                "aps":{
                    "alert": "Text push notification message.",
                    "content-available" : 1
                },
                "system": {
                    "iam": {
                        "type": "modal",
                        "displayType": "displayImmediately",
                        "inactiveSessionDisplay": "show-in-app"
                    }
                },
                "deepLink": {
                    "url": "\(self.testDeepLinkURL)",
                    "fallbackUrl": "\(self.testDeepLinkFallbackURL)"
                },
                "mcID": "\(self.testMcId)"
            }
        """
    }
    
    func testAPNsToken() {
        let mock = MockRequestSenderRemoteNotificationsDeviceToken()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        
        if let deviceToken = Data(base64Encoded: self.testDeviceToken) {
            CordialSwizzlerHelper().didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
        }
        
        let expectation = XCTestExpectation(description: "Expectation for ending token preparing")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testRemoteNotificationStatus() {
        let mock = MockRequestSenderRemoteNotificationStatus()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        
        if let deviceToken = Data(base64Encoded: self.testDeviceToken) {
            CordialSwizzlerHelper().didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
        }
        
        let expectation = XCTestExpectation(description: "Expectation for ending token preparing")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testRemoteNotificationsHasBeenTapped() {
        let mock = MockRequestSenderRemoteNotificationsHasBeenTapped()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        if let testPushNotificationData = self.testPushNotification.data(using: .utf8),
            let userInfo = try? JSONSerialization.jsonObject(with: testPushNotificationData, options: []) as? [AnyHashable : Any] {
            
            CordialPushNotificationHelper().pushNotificationHasBeenTapped(userInfo: userInfo)
        }
        
        let expectation = XCTestExpectation(description: "Expectation for sending event")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testRemoteNotificationsHasBeenForegroundDelivered() {
        let mock = MockRequestSenderRemoteNotificationsHasBeenForegroundDelivered()

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()

        if let testPushNotificationData = self.testPushNotification.data(using: .utf8),
            let userInfo = try? JSONSerialization.jsonObject(with: testPushNotificationData, options: []) as? [AnyHashable : Any] {
            
            CordialPushNotificationHelper().pushNotificationHasBeenForegroundDelivered(userInfo: userInfo)
        }

        let expectation = XCTestExpectation(description: "Expectation for sending event")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testRemoteNotificationsHasBeenTappedWithMcId() {
        let mock = MockRequestSenderRemoteNotificationsHasBeenTappedWithMcId()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        if let testPushNotificationData = self.testPushNotification.data(using: .utf8),
            let userInfo = try? JSONSerialization.jsonObject(with: testPushNotificationData, options: []) as? [AnyHashable : Any] {
            
            CordialPushNotificationHelper().pushNotificationHasBeenTapped(userInfo: userInfo)
        }
        
        let expectation = XCTestExpectation(description: "Expectation for sending event")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testDeepLinkDelegate() {
        let mock = MockPushNotificationHandlerDeepLinkDelegate()
        
        CordialApiConfiguration.shared.cordialDeepLinksDelegate = mock
        DependencyConfiguration.shared.requestSender = EmptyMockRequestSender()
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        if let testPushNotificationData = self.testPushNotification.data(using: .utf8),
            let userInfo = try? JSONSerialization.jsonObject(with: testPushNotificationData, options: []) as? [AnyHashable : Any] {
            
            CordialPushNotificationHelper().pushNotificationHasBeenTapped(userInfo: userInfo)
        }
        
        XCTAssert(mock.isVerified)
    }
    
    func testSetContact() {
        let mock = MockRequestSenderSetContact()

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setTestPushNotificationToken(token: self.testDeviceToken)
        
        self.cordialAPI.setContact(primaryKey: self.testPrimaryKey)
        
        XCTAssert(mock.isVerified)
    }
    
    func testSetContactWithoutNotificationToken() {
        let mock = MockRequestSenderSetContactWithoutNotificationToken()
        
        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        
        self.cordialAPI.setContact(primaryKey: self.testPrimaryKey)
        
        XCTAssert(!mock.isCalled)
        
        self.testCase.setTestPushNotificationToken(token: self.testDeviceToken)
        self.cordialAPI.setContact(primaryKey: self.testPrimaryKey)
        
        XCTAssert(mock.isVerified)
    }

    func testUpsertContact() {
        let mock = MockRequestSenderUpsertContact()
        
        var testContactAttributes = Dictionary<String, AttributeValue>()
        testContactAttributes["StringKey"] = StringValue("StringValue")
        testContactAttributes["BooleanKey"] = BooleanValue(false)
        testContactAttributes["NumericKey"] = NumericValue(1.2)
        testContactAttributes["ArrayKey"] = ArrayValue(["1", "2", "3"])
        testContactAttributes["DateKey"] = DateValue(Date())
        
        let geoValue = GeoValue()
        geoValue.setCity("San Diego")
        geoValue.setCountry("United States of America")
        geoValue.setPostalCode("90001")
        geoValue.setState("California")
        geoValue.setStreetAddress("402 West Broadway, Suite 700")
        geoValue.setStreetAddress2("402 West Broadway, Suite 700")
        geoValue.setTimeZone("America/Los_Angeles")
        
        testContactAttributes["GeoKey"] = geoValue
        
        mock.testContactAttributes = testContactAttributes

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setTestPushNotificationToken(token: self.testDeviceToken)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        
        self.cordialAPI.upsertContact(attributes: testContactAttributes)
        
        XCTAssert(mock.isVerified)
    }
    
    func testUnsetContact() {
        let mock = MockRequestSenderUnsetContact()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setTestPushNotificationToken(token: self.testDeviceToken)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        
         self.cordialAPI.unsetContact()
        
        XCTAssert(mock.isVerified)
    }
    
    func testSDKSecurityAbsentJWT() {
        let mock = MockRequestSenderSDKSecurity()

        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestPushNotificationToken(token: self.testDeviceToken)
        
        self.cordialAPI.setContact(primaryKey: self.testPrimaryKey)
        
        let expectation = XCTestExpectation(description: "Expectation for sending event")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testSDKSecurityNotValidJWT() {
        let mock = MockRequestSenderSDKSecurity()

        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setTestPushNotificationToken(token: self.testDeviceToken)
        
        self.cordialAPI.setContact(primaryKey: self.testPrimaryKey)
        
        let expectation = XCTestExpectation(description: "Expectation for sending event")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    // Guest -> PK (BD - | mcID -)
    func testNotClearMcIdIfLoginWithPrimaryKeyInGuestMode() {
        let mock = MockRequestSenderSaveMcIdAfterSetContact()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setTestPushNotificationToken(token: self.testDeviceToken)
        self.testCase.markUserAsLoggedIn()
        
        CordialAPI().setCurrentMcID(mcID: self.testMcId)
        
        self.cordialAPI.setContact(primaryKey: self.testPrimaryKey)
        
        XCTAssert(mock.isVerified)
    }
    
    // Guest -> Guest (BD - | mcID -)
    func testNotClearMcIdIfLoginWithoutPrimaryKeyInGuestMode() {
        let mock = MockRequestSenderSaveMcIdAfterSetContact()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setTestPushNotificationToken(token: self.testDeviceToken)
        self.testCase.markUserAsLoggedIn()
        
        CordialAPI().setCurrentMcID(mcID: self.testMcId)
        
        self.cordialAPI.setContact(primaryKey: nil)
        
        XCTAssert(mock.isVerified)
    }
    
    // PK -> PK && PK == PK (BD - | mcID -)
    func testNotClearMcIdIfLoginWithTheSamePrimaryKeyInLoginMode() {
        let mock = MockRequestSenderSaveMcIdAfterSetContact()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setTestPushNotificationToken(token: self.testDeviceToken)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        CordialAPI().setCurrentMcID(mcID: self.testMcId)
        
        self.cordialAPI.setContact(primaryKey: self.testPrimaryKey)
        
        XCTAssert(mock.isVerified)
    }
    
    // PK -> Guest (BD + | mcID +)
    func testClearMcIdIfLoginWithoutPrimaryKeyInLoginMode() {
        let mock = MockRequestSenderNotSaveMcIdAfterSetContact()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setTestPushNotificationToken(token: self.testDeviceToken)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        CordialAPI().setCurrentMcID(mcID: self.testMcId)
        
        self.cordialAPI.setContact(primaryKey: nil)
        
        XCTAssert(mock.isVerified)
    }
    
    // PK -> PK && PK != PK (BD + | mcID +)
    func testClearMcIdIfLoginWithNotTheSamePrimaryKeyInLoginMode() {
        let mock = MockRequestSenderNotSaveMcIdAfterSetContact()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setTestPushNotificationToken(token: self.testDeviceToken)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        CordialAPI().setCurrentMcID(mcID: self.testMcId)
        
        self.cordialAPI.setContact(primaryKey: "new_\(self.testPrimaryKey)")
        
        XCTAssert(mock.isVerified)
    }
    
    func testEventsBulkSizeCount() {
        let mock = MockRequestSenderEventsBulkSizeCount()
        
        let events = ["test_custom_event_1", "test_custom_event_2", "test_custom_event_3"]
        mock.events = events

        DependencyConfiguration.shared.requestSender = mock

        CordialApiConfiguration.shared.eventsBulkSize = 3
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        events.forEach { event in
            CordialAPI().sendCustomEvent(eventName: event, properties: nil)
        }
        
        let expectation = XCTestExpectation(description: "Expectation for sending event")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testEventsBulkSizeTimer() {
        let mock = MockRequestSenderEventsBulkSizeTimer()
        
        let event = "test_custom_event_1"
        mock.event = event

        DependencyConfiguration.shared.requestSender = mock

        CordialApiConfiguration.shared.eventsBulkSize = 3
        CordialApiConfiguration.shared.eventsBulkUploadInterval = 1
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        let expectation = XCTestExpectation(description: "Expectation for start scheduled timer")
        
        CordialAPI().sendCustomEvent(eventName: event, properties: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testEventsBulkSizeAppClose() {
        let mock = MockRequestSenderEventsBulkSizeAppClose()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        self.testCase.appMovedToBackground()
        
        let expectation = XCTestExpectation(description: "Expectation for sending event")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testEventsBulkSizeReachability() {
        let mock = MockRequestSenderEventsBulkSizeReachability()
        
        let event = "test_custom_event_1"
        mock.event = event
        
        DependencyConfiguration.shared.requestSender = mock
        
        CordialApiConfiguration.shared.eventsBulkSize = 3
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        CordialAPI().sendCustomEvent(eventName: event, properties: nil)
        
        self.testCase.reachabilitySenderMakeAllNeededHTTPCalls()
        
        let expectation = XCTestExpectation(description: "Expectation for sending event")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testQtyCachedEventQueue() {
        let mock = MockRequestSenderQtyCachedEventQueue()
        
        let events = ["test_custom_event_1", "test_custom_event_2", "test_custom_event_3", "test_custom_event_4", "test_custom_event_5"]

        DependencyConfiguration.shared.requestSender = mock

        CordialApiConfiguration.shared.qtyCachedEventQueue = 3
        CordialApiConfiguration.shared.eventsBulkSize = 5
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        events.forEach { event in
            CordialAPI().sendCustomEvent(eventName: event, properties: nil)
        }
        
        self.cordialAPI.flushEvents(reason: "Test qty cached events queue")
        
        let expectation = XCTestExpectation(description: "Expectation for sending event")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testSystemEventsProperties() {
        let mock = MockRequestSenderSystemEventsProperties()
        
        DependencyConfiguration.shared.requestSender = mock
        
        let systemEventsProperties = ["systemEventsPropertiesKey": "systemEventsPropertiesValue"]
        mock.systemEventsProperties = systemEventsProperties
        CordialApiConfiguration.shared.systemEventsProperties = systemEventsProperties
            
        CordialApiConfiguration.shared.eventsBulkSize = 1
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        self.testCase.appMovedToBackground()
        
        let expectation = XCTestExpectation(description: "Expectation for sending event")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }

    
    func testEventsIfRequestHasInvalidEvent() {
        let mock = MockRequestSenderIfEventRequestHasInvalidEvent()
        
        let validEventNames = ["test_valid_event_1", "test_valid_event_2"]
        mock.validEventNames = validEventNames
        
        let invalidEventName = "test_invalid_event"
        mock.invalidEventName = invalidEventName

        DependencyConfiguration.shared.requestSender = mock

        CordialApiConfiguration.shared.eventsBulkSize = 2
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        CordialAPI().sendCustomEvent(eventName: invalidEventName, properties: nil)
        validEventNames.forEach { validEventName in
            CordialAPI().sendCustomEvent(eventName: validEventName, properties: nil)
        }
        
        let expectation = XCTestExpectation(description: "Expectation for sending event")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testUpsertContactCartOneItem() {
        let mock = MockRequestSenderUpsertContactCartOneItem()
        
        let cartItemID = "test_ID"
        
        mock.cartItemIDs.append(cartItemID)
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        let cartItem = CartItem(productID: cartItemID, name: String(), sku: String(), category: nil, url: nil, itemDescription: nil, qty: 1, itemPrice: 20, salePrice: 20, attr: nil, images: nil, properties: nil)

        let cartItems = [cartItem]

        CordialAPI().upsertContactCart(cartItems: cartItems)
        
        XCTAssert(mock.isVerified)
    }
    
    func testUpsertContactCartEmptyCart() {
        let mock = MockRequestSenderUpsertContactCartEmptyCart()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()

        let cartItems = [CartItem]()

        CordialAPI().upsertContactCart(cartItems: cartItems)
        
        XCTAssert(mock.isVerified)
    }
    
    func testUpsertContactCartReachability() {
        let mock = MockRequestSenderUpsertContactCartReachability()
        
        let cartItemID = "test_ID"
        
        mock.cartItemIDs.append(cartItemID)
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        let cartItem = CartItem(productID: cartItemID, name: String(), sku: String(), category: nil, url: nil, itemDescription: nil, qty: 1, itemPrice: 20, salePrice: 20, attr: nil, images: nil, properties: nil)

        self.testCase.setContactCartRequestToCoreData(cartItems: [cartItem])

        self.testCase.reachabilitySenderMakeAllNeededHTTPCalls()
        
        let expectation = XCTestExpectation(description: "Expectation for sending event")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testUpsertContactCartReachabilityTwoCarts() {
        let mock = MockRequestSenderUpsertContactCartReachabilityTwoCarts()
        
        let cartItemID_1 = "test_ID_1"
        let cartItemID_2 = "test_ID_2"
        
        mock.cartItemIDs.append(cartItemID_2)
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        let cartItem_1 = CartItem(productID: cartItemID_1, name: String(), sku: String(), category: nil, url: nil, itemDescription: nil, qty: 1, itemPrice: 20, salePrice: 20, attr: nil, images: nil, properties: nil)
        
        self.testCase.setContactCartRequestToCoreData(cartItems: [cartItem_1])
        
        let cartItem_2 = CartItem(productID: cartItemID_2, name: String(), sku: String(), category: nil, url: nil, itemDescription: nil, qty: 1, itemPrice: 20, salePrice: 20, attr: nil, images: nil, properties: nil)
        
        self.testCase.setContactCartRequestToCoreData(cartItems: [cartItem_2])
        
        self.testCase.reachabilitySenderMakeAllNeededHTTPCalls()
        
        let expectation = XCTestExpectation(description: "Expectation for sending event")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
    }
    
    func testUserAgent() {
        let mock = MockRequestSenderUserAgent()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        self.testCase.appMovedToBackground()
        
        let expectation = XCTestExpectation(description: "Expectation for sending event")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testSendContactOrder() {
        let mock = MockRequestSenderSendContactOrder()
        
        let orderID = "test_order_ID"
        mock.orderID = orderID
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        let shippingAddress = Address(name: "shippingAddressName", address: "shippingAddress", city: "shippingAddressCity", state: "shippingAddressState", postalCode: "shippingAddressPostalCode", country: "shippingAddressCountry")

        let billingAddress = Address(name: "billingAddressName", address: "billingAddress", city: "billingAddressCity", state: "billingAddressState", postalCode: "billingAddressPostalCode", country: "billingAddressCountry")

        let cartItem = CartItem(productID: "productID", name: "productName", sku: "productSKU", category: nil, url: nil, itemDescription: nil, qty: 1, itemPrice: 20, salePrice: 20, attr: nil, images: nil, properties: nil)

        let cartItems = [cartItem]

        let order = Order(orderID: orderID, status: "orderStatus", storeID: "storeID", customerID: "customerID", shippingAddress: shippingAddress, billingAddress: billingAddress, items: cartItems, tax: nil, shippingAndHandling: nil, properties: nil)

        CordialAPI().sendContactOrder(order: order)
        
        XCTAssert(mock.isVerified)
    }
    
    func testSendContactOrderReachability() {
        let mock = MockRequestSenderSendContactOrder()
        
        let orderID = "test_order_ID"
        mock.orderID = orderID
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        let shippingAddress = Address(name: "shippingAddressName", address: "shippingAddress", city: "shippingAddressCity", state: "shippingAddressState", postalCode: "shippingAddressPostalCode", country: "shippingAddressCountry")

        let billingAddress = Address(name: "billingAddressName", address: "billingAddress", city: "billingAddressCity", state: "billingAddressState", postalCode: "billingAddressPostalCode", country: "billingAddressCountry")

        let cartItem = CartItem(productID: "productID", name: "productName", sku: "productSKU", category: nil, url: nil, itemDescription: nil, qty: 1, itemPrice: 20, salePrice: 20, attr: nil, images: nil, properties: nil)

        let cartItems = [cartItem]

        let order = Order(orderID: orderID, status: "orderStatus", storeID: "storeID", customerID: "customerID", shippingAddress: shippingAddress, billingAddress: billingAddress, items: cartItems, tax: nil, shippingAndHandling: nil, properties: nil)

        self.testCase.setContactOrderRequestToCoreData(order: order)

        self.testCase.reachabilitySenderMakeAllNeededHTTPCalls()
        
        let expectation = XCTestExpectation(description: "Expectation for sending event")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testSendContactOrderReachabilityTwoOrders() {
        let mock = MockRequestSenderSendContactOrderTwoOrders()
        
        let orderID_1 = "test_order_ID_1"
        let orderID_2 = "test_order_ID_2"
        
        mock.orderID_1 = orderID_1
        mock.orderID_2 = orderID_2
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        let shippingAddress = Address(name: "shippingAddressName", address: "shippingAddress", city: "shippingAddressCity", state: "shippingAddressState", postalCode: "shippingAddressPostalCode", country: "shippingAddressCountry")

        let billingAddress = Address(name: "billingAddressName", address: "billingAddress", city: "billingAddressCity", state: "billingAddressState", postalCode: "billingAddressPostalCode", country: "billingAddressCountry")

        let cartItem = CartItem(productID: "productID", name: "productName", sku: "productSKU", category: nil, url: nil, itemDescription: nil, qty: 1, itemPrice: 20, salePrice: 20, attr: nil, images: nil, properties: nil)

        let cartItems = [cartItem]

        let order_1 = Order(orderID: orderID_1, status: "orderStatus", storeID: "storeID", customerID: "customerID", shippingAddress: shippingAddress, billingAddress: billingAddress, items: cartItems, tax: nil, shippingAndHandling: nil, properties: nil)

        let order_2 = Order(orderID: orderID_2, status: "orderStatus", storeID: "storeID", customerID: "customerID", shippingAddress: shippingAddress, billingAddress: billingAddress, items: cartItems, tax: nil, shippingAndHandling: nil, properties: nil)
        
        self.testCase.setContactOrderRequestToCoreData(order: order_1)
        
        self.testCase.setContactOrderRequestToCoreData(order: order_2)

        self.testCase.reachabilitySenderMakeAllNeededHTTPCalls()
        
        let expectation = XCTestExpectation(description: "Expectation for sending event")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testInAppMessageHasBeenShown() {
        let mock = MockRequestSenderInAppMessageHasBeenShown()

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()

        if let testSilentNotificationData = self.testSilentNotification.data(using: .utf8),
            let userInfo = try? JSONSerialization.jsonObject(with: testSilentNotificationData, options: []) as? [AnyHashable : Any] {

            CordialSwizzlerHelper().didReceiveRemoteNotification(userInfo: userInfo)
        }

        let expectation = XCTestExpectation(description: "Expectation for IAM delay show")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            
            InAppMessageProcess.shared.isPresentedInAppMessage = false
            
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)
    }
    
    func testInAppMessageHasBeenShownReachability() {
        let mock = MockRequestSenderInAppMessageHasBeenShown()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        if let testSilentNotificationData = self.testSilentNotification.data(using: .utf8),
            let userInfo = try? JSONSerialization.jsonObject(with: testSilentNotificationData, options: []) as? [AnyHashable : Any] {
            
            if CordialPushNotificationParser().isPayloadContainIAM(userInfo: userInfo) {
                InAppMessageGetter().setInAppMessagesParamsToCoreData(userInfo: userInfo)
                CoreDataManager.shared.inAppMessagesQueue.setMcIdToCoreDataInAppMessagesQueue(mcID: self.testMcId)
            }
        }
        
        let expectation = XCTestExpectation(description: "Expectation for IAM delay show")
        
        self.testCase.reachabilitySenderMakeAllNeededHTTPCalls()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            
            InAppMessageProcess.shared.isPresentedInAppMessage = false
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testInAppMessageHasBeenShownTwoTimes() {
        let mock = MockRequestSenderInAppMessageHasBeenShownTwoTimes()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        if let testSilentNotificationData = self.testSilentNotification.data(using: .utf8),
            let userInfo = try? JSONSerialization.jsonObject(with: testSilentNotificationData, options: []) as? [AnyHashable : Any] {
            
            CordialSwizzlerHelper().didReceiveRemoteNotification(userInfo: userInfo)
        }
                
        let expectation = XCTestExpectation(description: "Expectation for IAM delay show")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let testMcId_2 = "\(self.testMcId)_2"
            
            let testSilentNotification = self.testSilentNotification.replacingOccurrences(of: self.testMcId, with: testMcId_2)
            
            if let testSilentNotificationData = testSilentNotification.data(using: .utf8),
                let userInfo = try? JSONSerialization.jsonObject(with: testSilentNotificationData, options: []) as? [AnyHashable : Any] {

                if CordialPushNotificationParser().isPayloadContainIAM(userInfo: userInfo) {
                    InAppMessageGetter().setInAppMessagesParamsToCoreData(userInfo: userInfo)
                    CoreDataManager.shared.inAppMessagesQueue.setMcIdToCoreDataInAppMessagesQueue(mcID: testMcId_2)
                }
            }

            InAppMessageProcess.shared.isPresentedInAppMessage = false
            
            self.testCase.reachabilitySenderMakeAllNeededHTTPCalls()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                XCTAssert(mock.isVerified)
                
                InAppMessageProcess.shared.isPresentedInAppMessage = false
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 4)
    }
    
    func testInAppMessageDelayedShow() {
        let mock = MockRequestSenderInAppMessageHasBeenShown()

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()

        CordialApiConfiguration.shared.inAppMessageDelayMode.delayedShow()
        
        if let testSilentNotificationData = self.testSilentNotification.data(using: .utf8),
            let userInfo = try? JSONSerialization.jsonObject(with: testSilentNotificationData, options: []) as? [AnyHashable : Any] {

            CordialSwizzlerHelper().didReceiveRemoteNotification(userInfo: userInfo)
        }
        
        let expectation = XCTestExpectation(description: "Expectation for IAM delay show")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            CordialApiConfiguration.shared.inAppMessageDelayMode.show()
            
            InAppMessageProcess.shared.showInAppMessageIfPopupCanBePresented()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                XCTAssert(mock.isVerified)
                
                InAppMessageProcess.shared.isPresentedInAppMessage = false
                
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)
    }
    
    func testInAppMessageInactiveSessionDisplay() {
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()

        let testSilentAndPushNotifications = self.testSilentAndPushNotifications.replacingOccurrences(of: "show-in-app", with: "hide-in-app")

        if let testSilentNotificationData = testSilentAndPushNotifications.data(using: .utf8),
            let userInfo = try? JSONSerialization.jsonObject(with: testSilentNotificationData, options: []) as? [AnyHashable : Any] {

            if CordialPushNotificationParser().isPayloadContainIAM(userInfo: userInfo) {
                InAppMessageGetter().setInAppMessagesParamsToCoreData(userInfo: userInfo)
                CoreDataManager.shared.inAppMessagesQueue.setMcIdToCoreDataInAppMessagesQueue(mcID: self.testMcId)
                
                if let inAppMessageParams = CoreDataManager.shared.inAppMessagesParam.fetchInAppMessageParamsByMcID(mcID: self.testMcId), inAppMessageParams.inactiveSessionDisplay == InAppMessageInactiveSessionDisplayType.hideInAppMessage {
                    
                    InAppMessageProcess.shared.deleteInAppMessageFromCoreDataByMcID(mcID: self.testMcId)
                }
            }
        }

        if CoreDataManager.shared.inAppMessagesParam.fetchInAppMessageParamsByMcID(mcID: self.testMcId) == nil {
            XCTAssert(true, "IAM has been removed successfully")
        } else {
            XCTAssert(false, "IAM has not been removed")
        }
    }
    
    func testInAppMessageDisplayType() {
        let mock = MockRequestSenderInAppMessageHasBeenShown()

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        let testSilentNotification = self.testSilentNotification.replacingOccurrences(of: "displayImmediately", with: "displayOnAppOpenEvent")

        if let testSilentNotificationData = testSilentNotification.data(using: .utf8),
            let userInfo = try? JSONSerialization.jsonObject(with: testSilentNotificationData, options: []) as? [AnyHashable : Any] {

            CordialSwizzlerHelper().didReceiveRemoteNotification(userInfo: userInfo)
        }
        
        let expectation = XCTestExpectation(description: "Expectation for IAM delay show")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            if InAppMessageProcess.shared.isPresentedInAppMessage {
                XCTAssert(false, "IAM has been presented")
            }
            
            InAppMessageProcess.shared.showInAppMessageIfPopupCanBePresented()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                XCTAssert(mock.isVerified)
                
                InAppMessageProcess.shared.isPresentedInAppMessage = false
                
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)
    }
    
    func testInAppMessageBannerAutoDismiss() {
        let mock = MockRequestSenderInAppMessageBannerAutoDismiss()

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        let testSilentNotification = self.testSilentNotification.replacingOccurrences(of: "modal", with: "banner_up")

        if let testSilentNotificationData = testSilentNotification.data(using: .utf8),
            let userInfo = try? JSONSerialization.jsonObject(with: testSilentNotificationData, options: []) as? [AnyHashable : Any] {

            CordialSwizzlerHelper().didReceiveRemoteNotification(userInfo: userInfo)
        }

        let expectation = XCTestExpectation(description: "Expectation for IAM delay show")

        DispatchQueue.main.asyncAfter(deadline: .now() + 19) {
            XCTAssert(mock.isVerified)
            
            InAppMessageProcess.shared.isPresentedInAppMessage = false
            
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 20)
    }
    
    func testInAppMessageBannerManualDismiss() {
        let mock = MockRequestSenderInAppMessageManualDismiss()

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        let testSilentNotification = self.testSilentNotification.replacingOccurrences(of: "modal", with: "banner_bottom")

        if let testSilentNotificationData = testSilentNotification.data(using: .utf8),
            let userInfo = try? JSONSerialization.jsonObject(with: testSilentNotificationData, options: []) as? [AnyHashable : Any] {

            CordialSwizzlerHelper().didReceiveRemoteNotification(userInfo: userInfo)
        }

        let expectation = XCTestExpectation(description: "Expectation for IAM delay show")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            InAppMessageProcess.shared.inAppMessageManager.inAppMessageViewController.removeBannerFromSuperviewWithAnimation(eventName: API.EVENT_NAME_MANUAL_REMOVE_IN_APP_MESSAGE, duration: InAppMessageProcess.shared.bannerAnimationDuration)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                XCTAssert(mock.isVerified)
                
                InAppMessageProcess.shared.isPresentedInAppMessage = false
                
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 6)
    }
    
    func testInAppMessageFullscreenManualDismiss() {
        let mock = MockRequestSenderInAppMessageManualDismiss()

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        let testSilentNotification = self.testSilentNotification.replacingOccurrences(of: "modal", with: "fullscreen")

        if let testSilentNotificationData = testSilentNotification.data(using: .utf8),
            let userInfo = try? JSONSerialization.jsonObject(with: testSilentNotificationData, options: []) as? [AnyHashable : Any] {

            CordialSwizzlerHelper().didReceiveRemoteNotification(userInfo: userInfo)
        }

        let expectation = XCTestExpectation(description: "Expectation for IAM delay show")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            InAppMessageProcess.shared.inAppMessageManager.inAppMessageViewController.dismissModalInAppMessage()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                XCTAssert(mock.isVerified)
                
                InAppMessageProcess.shared.isPresentedInAppMessage = false
                
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3)
    }
    
    func testInAppMessageUserClickedInAppMessageActionButton() {
        let mock = MockRequestSenderInAppMessageUserClickedInAppMessageActionButton()
        
        let eventName = "test_event_name"
        mock.eventName = eventName
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()

        if let testSilentNotificationData = self.testSilentNotification.data(using: .utf8),
            let userInfo = try? JSONSerialization.jsonObject(with: testSilentNotificationData, options: []) as? [AnyHashable : Any] {

            CordialSwizzlerHelper().didReceiveRemoteNotification(userInfo: userInfo)
        }

        let expectation = XCTestExpectation(description: "Expectation for IAM delay show")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            let messageBody = ["deepLink": self.testDeepLinkURL,  "eventName": eventName]
            
            InAppMessageProcess.shared.inAppMessageManager.inAppMessageViewController.userClickedInAppMessageActionButton(messageBody: messageBody)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                XCTAssert(mock.isVerified)
                
                InAppMessageProcess.shared.isPresentedInAppMessage = false
                
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3)
    }
    
    func testInAppMessageExpirationTime() {
        let mock = MockRequestSenderInAppMessageExpirationTime()

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()

        let testSilentNotification = self.testSilentNotification.replacingOccurrences(of: "\"inactiveSessionDisplay\": \"show-in-app\"", with: "\"inactiveSessionDisplay\": \"show-in-app\", \"expirationTime\":\"\(CordialDateFormatter().getCurrentTimestamp())\"")

         let expectation = XCTestExpectation(description: "Expectation for IAM delay show")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
             if let testSilentNotificationData = testSilentNotification.data(using: .utf8),
                 let userInfo = try? JSONSerialization.jsonObject(with: testSilentNotificationData, options: []) as? [AnyHashable : Any] {

                 CordialSwizzlerHelper().didReceiveRemoteNotification(userInfo: userInfo)
             }

             DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                 XCTAssert(mock.isVerified)

                 InAppMessageProcess.shared.isPresentedInAppMessage = false

                 expectation.fulfill()
             }
        }

        wait(for: [expectation], timeout: 3)
    }
}

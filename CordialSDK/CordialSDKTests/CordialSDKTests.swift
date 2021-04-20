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
    
    let validStringURL = "https://cordial.com/"
    let testDeviceToken = "ffa29a48a76025c0ff73a2cb2a6ad50266114c03b3f612e824d61be7c9a0f4cb"
    let testPrimaryKey = "test_primary_key@gmail.com"
    let testJWT = "testJWT"
    let testMcID = "test_mc_id"
    var testPushNotification = String()
    var testSilentNotification = String()
    var testSilentAndPushNotifications = String()
    let testDeepLinkURL = "https://tjs.cordialdev.com/prep-tj1.html"
    let testDeepLinkFallbackURL = "https://tjs.cordialdev.com/prep-tj2.html"
    let testEmailDeepLinkURL = "https://e.a45.clients.cordialdev.com/c/45:5ffdd4ba20c3e66cfb62ecdc:ot:5e6b9936102e517f8c04870a:1/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MTA0NzA2OTAsImNkIjoiLmE0NS5jbGllbnRzLmNvcmRpYWxkZXYuY29tIiwiY2UiOjg2NDAwLCJ0ayI6ImNvcmRpYWxkZXYiLCJtdGxJRCI6IjVmZmRkNTIyZTg0ZWYxMmViNzI0OTk4NSIsIm1jTGlua0lEIjoiOWM4MTg2NDEiLCJsaW5rVXJsIjoiaHR0cHM6XC9cL3Rqcy5jb3JkaWFsZGV2LmNvbVwvcHJlcC10ajEuaHRtbD91dG1fY2FtcGFpZ249YXNoaWVsZHMrZGVlcCtsaW5rK3Rlc3QmdXRtX3NvdXJjZT1jb3JkaWFsJnV0bV9tZWRpdW09ZW1haWwmbWNpRD00NSUzQTVmZmRkNGJhMjBjM2U2NmNmYjYyZWNkYyUzQW90JTNBNWU2Yjk5MzYxMDJlNTE3ZjhjMDQ4NzBhJTNBMSYlMjRsaW5rPSYlN0Vjb250YWN0PTVlNmI5OTM2MTAyZTUxN2Y4YzA0ODcwYSJ9.eKSz8ys89tesz5dK8JulvznPDCAwDxDXz5exU255Irc"
    let testSMSDeepLinkURL = "https://s.cordial.com/3udMLK"
    var testInboxMessagesPayload = String()
    var testInboxMessagePayload = String()
    var testInboxMessageContentPayload = "Cordial"
    
    override func setUp() {
        self.testCase.clearAllTestCaseData()
        
        CordialApiConfiguration.shared.initialize(accountKey: "qc-all-channels", channelKey: "push")
        CordialApiConfiguration.shared.osLogManager.setOSLogLevel(.none)
        CordialApiConfiguration.shared.qtyCachedEventQueue = 100
        CordialApiConfiguration.shared.eventsBulkSize = 1
        CordialApiConfiguration.shared.eventsBulkUploadInterval = 30
        CordialApiConfiguration.shared.pushNotificationDelegate = PushNotificationHandler()
        CordialApiConfiguration.shared.cordialDeepLinksDelegate = DeepLinksHandler()
        CordialApiConfiguration.shared.vanityDomains = ["e.a45.clients.cordialdev.com", "s.cordial.com"]
        
        self.testPushNotification = """
            {
                "aps":{
                    "alert": "Text push notification message."
                },
                "deepLink": {
                    "url": "\(self.testDeepLinkURL)",
                    "fallbackUrl": "\(self.testDeepLinkFallbackURL)"
                },
                "mcID": "\(self.testMcID)"
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
                    },
                    "inbox": {}
                },
                "mcID": "\(self.testMcID)"
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
                    },
                    "inbox": {}
                },
                "deepLink": {
                    "url": "\(self.testDeepLinkURL)",
                    "fallbackUrl": "\(self.testDeepLinkFallbackURL)"
                },
                "mcID": "\(self.testMcID)"
            }
        """
        
        self.testInboxMessagesPayload = """
            {
                "currentPage": 1,
                "lastPage": 1,
                "perPage": 10,
                "total": 1,
                "success": true,
                "messages": [
                    {
                        "_id": "\(self.testMcID)",
                        "url": "\(self.validStringURL)",
                        "urlExpireAt": "\(CordialDateFormatter().getCurrentTimestamp())",
                        "read": true,
                        "sentAt": "\(CordialDateFormatter().getCurrentTimestamp())",
                        "metadata":
                            {
                                "title": "Title",
                                "subtitle": "Subtitle",
                                "imageUrl": "\(self.validStringURL)"
                            }
                    }
                ]
            }
        """
        
        self.testInboxMessagePayload = self.getTestInboxMessagePayload()
    }
    
    private func getTestInboxMessagePayload() -> String {
        return """
            {
                "success": true,
                "message":
                    {
                        "url": "\(self.validStringURL)",
                        "urlExpireAt": "\(CordialDateFormatter().getCurrentTimestamp())",
                        "read": true,
                        "sentAt": "\(CordialDateFormatter().getCurrentTimestamp())",
                        "metadata":
                            {
                                "title": "Title",
                                "subtitle": "Subtitle",
                                "url": "\(self.validStringURL)"
                            }
                    }
            }
        """
    }
    
    func testAPNsToken() {
        let mock = MockRequestSenderRemoteNotificationsDeviceToken()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
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
        self.testCase.setTestPushNotificationToken(token: self.testDeviceToken)
        
        self.testCase.prepareCurrentPushNotificationStatus()
        
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
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
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

        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testRemoteNotificationsHasBeenTappedWithDeepLink() {
        let mock = MockRequestSenderRemoteNotificationsHasBeenTappedWithDeepLink()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        if let testPushNotificationData = self.testPushNotification.data(using: .utf8),
            let userInfo = try? JSONSerialization.jsonObject(with: testPushNotificationData, options: []) as? [AnyHashable : Any] {
            
            CordialPushNotificationHelper().pushNotificationHasBeenTapped(userInfo: userInfo)
        }
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
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
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testDeepLinkDelegate() {
        let mock = MockPushNotificationDeepLinkDelegate()
        
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
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
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
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
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
        
        CordialAPI().setCurrentMcID(mcID: self.testMcID)
        
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
        
        CordialAPI().setCurrentMcID(mcID: self.testMcID)
        
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
        
        CordialAPI().setCurrentMcID(mcID: self.testMcID)
        
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
        
        CordialAPI().setCurrentMcID(mcID: self.testMcID)
        
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
        
        CordialAPI().setCurrentMcID(mcID: self.testMcID)
        
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
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
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
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
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
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
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
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
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
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
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
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
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
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
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
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
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
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
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
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
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
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
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
                InAppMessageGetter().setInAppMessageParamsToCoreData(userInfo: userInfo)
                CoreDataManager.shared.inAppMessagesQueue.setMcIDsToCoreDataInAppMessagesQueue(mcIDs: [self.testMcID])
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
            let testMcID_2 = "\(self.testMcID)_2"
            
            let testSilentNotification = self.testSilentNotification.replacingOccurrences(of: self.testMcID, with: testMcID_2)
            
            if let testSilentNotificationData = testSilentNotification.data(using: .utf8),
                let userInfo = try? JSONSerialization.jsonObject(with: testSilentNotificationData, options: []) as? [AnyHashable : Any] {

                if CordialPushNotificationParser().isPayloadContainIAM(userInfo: userInfo) {
                    InAppMessageGetter().setInAppMessageParamsToCoreData(userInfo: userInfo)
                    CoreDataManager.shared.inAppMessagesQueue.setMcIDsToCoreDataInAppMessagesQueue(mcIDs: [testMcID_2])
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

        if let testSilentAndPushNotificationsData = testSilentAndPushNotifications.data(using: .utf8),
            let userInfo = try? JSONSerialization.jsonObject(with: testSilentAndPushNotificationsData, options: []) as? [AnyHashable : Any] {

            if CordialPushNotificationParser().isPayloadContainIAM(userInfo: userInfo) {
                InAppMessageGetter().setInAppMessageParamsToCoreData(userInfo: userInfo)
                CoreDataManager.shared.inAppMessagesQueue.setMcIDsToCoreDataInAppMessagesQueue(mcIDs: [self.testMcID])
                
                if let inAppMessageParams = CoreDataManager.shared.inAppMessagesParam.fetchInAppMessageParamsByMcID(mcID: self.testMcID), inAppMessageParams.inactiveSessionDisplay == InAppMessageInactiveSessionDisplayType.hideInAppMessage {
                    
                    InAppMessageProcess.shared.deleteInAppMessageFromCoreDataByMcID(mcID: self.testMcID)
                }
            }
        }

        if CoreDataManager.shared.inAppMessagesParam.fetchInAppMessageParamsByMcID(mcID: self.testMcID) == nil {
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
        CordialApiConfiguration.shared.inAppMessagesDeliveryType = .silentPushes
        
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
            
            InAppMessageProcess.shared.inAppMessageManager.getInAppMessageViewController().removeBannerFromSuperviewWithAnimation(eventName: API.EVENT_NAME_MANUAL_REMOVE_IN_APP_MESSAGE, duration: InAppMessageProcess.shared.bannerAnimationDuration)
            
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
            
            InAppMessageProcess.shared.inAppMessageManager.getInAppMessageViewController().dismissModalInAppMessage()
            
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
            
            InAppMessageProcess.shared.inAppMessageManager.getInAppMessageViewController().userClickedAnyInAppMessageButton(messageBody: messageBody)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                XCTAssert(mock.isVerified)
                
                InAppMessageProcess.shared.isPresentedInAppMessage = false
                
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 4)
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
            
    func testInboxMessagesCache() {
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        var isVerified = false
        
        if let testInboxMessagesPayloadData = self.testInboxMessagesPayload.data(using: .utf8),
           let url = URL(string: self.validStringURL) {
            
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            let mockSession = MockURLSession(completionHandler: (testInboxMessagesPayloadData, response, nil))
            
            DependencyConfiguration.shared.inboxMessagesURLSession = mockSession
            
            let pageRequest = PageRequest(page: 1, size: 10)
            let inboxFilter = InboxFilter(isRead: .yes, fromDate: Date(), toDate: Date())
            CordialInboxMessageAPI().fetchInboxMessages(pageRequest: pageRequest, inboxFilter: inboxFilter, onSuccess: { inboxPage in
                if inboxPage.content.count == 1,
                   let inboxMessage = inboxPage.content.first,
                   CoreDataManager.shared.inboxMessagesCache.getInboxMessageFromCoreData(mcID: inboxMessage.mcID) != nil {
                    isVerified = true
                    XCTAssert(true)
                } else {
                    XCTAssert(false)
                }
            }, onFailure: { error in
                XCTAssert(false, error)
            })
        }
        
        XCTAssert(isVerified)
    }
    
    func testInboxMessageCache() {

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        var isVerified = false

        if let testInboxMessagesPayloadData = self.testInboxMessagePayload.data(using: .utf8),
           let url = URL(string: self.validStringURL) {

            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            let mockSession = MockURLSession(completionHandler: (testInboxMessagesPayloadData, response, nil))

            DependencyConfiguration.shared.inboxMessageURLSession = mockSession

            CordialInboxMessageAPI().fetchInboxMessage(mcID: self.testMcID, onSuccess: { inboxMessage in
                if CoreDataManager.shared.inboxMessagesCache.getInboxMessageFromCoreData(mcID: inboxMessage.mcID) != nil {
                    isVerified = true
                    XCTAssert(true)
                } else {
                    XCTAssert(false)
                }
            }, onFailure: { error in
                XCTAssert(false, error)
            })
        }
        
        XCTAssert(isVerified)
    }

    func testInboxMessageCacheExpire() {
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        var isVerified = false

        if let testInboxMessagePayloadData = self.testInboxMessagePayload.data(using: .utf8),
           let testInboxMessageContentPayloadData = self.testInboxMessageContentPayload.data(using: .utf8),
           let url = URL(string: self.validStringURL) {

            let responseInboxMessage = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            let mockSessionInboxMessage = MockURLSession(completionHandler: (testInboxMessagePayloadData, responseInboxMessage, nil))
            DependencyConfiguration.shared.inboxMessageURLSession = mockSessionInboxMessage
            
            let responseInboxMessageContent = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            let mockSessionInboxMessageContent = MockURLSession(completionHandler: (testInboxMessageContentPayloadData, responseInboxMessageContent, nil))
            DependencyConfiguration.shared.inboxMessageContentURLSession = mockSessionInboxMessageContent

            CordialInboxMessageAPI().fetchInboxMessage(mcID: self.testMcID, onSuccess: { inboxMessage in
                
                let testInboxMessagePayload2 = self.getTestInboxMessagePayload()
                
                if let testInboxMessagePayloadData2 = testInboxMessagePayload2.data(using: .utf8),
                   let testInboxMessageContentPayloadData2 = "\(self.testInboxMessageContentPayload)_2".data(using: .utf8) {
                        
                    let responseInboxMessage2 = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
                    let mockSessionInboxMessage2 = MockURLSession(completionHandler: (testInboxMessagePayloadData2, responseInboxMessage2, nil))
                    DependencyConfiguration.shared.inboxMessageURLSession = mockSessionInboxMessage2
                    
                    let responseInboxMessageContent2 = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
                    let mockSessionInboxMessageContent2 = MockURLSession(completionHandler: (testInboxMessageContentPayloadData2, responseInboxMessageContent2, nil))
                    DependencyConfiguration.shared.inboxMessageContentURLSession = mockSessionInboxMessageContent2
                    
                    CordialInboxMessageAPI().fetchInboxMessage(mcID: self.testMcID, onSuccess: { inboxMessage in
                        CordialInboxMessageAPI().fetchInboxMessageContent(mcID: self.testMcID, onSuccess: { content in
                            if content != self.testInboxMessageContentPayload {
                                isVerified = true
                                XCTAssert(true)
                            } else {
                                XCTAssert(false)
                            }
                        }, onFailure: { error in
                            XCTAssert(false, error)
                        })
                    }, onFailure: { error in
                        XCTAssert(false, error)
                    })
                } else {
                    XCTAssert(false)
                }
            }, onFailure: { error in
                XCTAssert(false, error)
            })
        }
        
        XCTAssert(isVerified)
    }
    
    func testInboxMessageContent() {
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        var isVerified = false
        
        CoreDataManager.shared.inboxMessagesContent.putInboxMessageContentToCoreData(mcID: self.testMcID, content: "\(self.testInboxMessageContentPayload)_2")
        
        if let testInboxMessagePayloadData = self.testInboxMessagePayload.data(using: .utf8),
           let testInboxMessageContentPayloadData = self.testInboxMessageContentPayload.data(using: .utf8),
           let url = URL(string: self.validStringURL) {

            let responseInboxMessage = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            let mockSessionInboxMessage = MockURLSession(completionHandler: (testInboxMessagePayloadData, responseInboxMessage, nil))
            DependencyConfiguration.shared.inboxMessageURLSession = mockSessionInboxMessage
            
            let responseInboxMessageContent = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            let mockSessionInboxMessageContent = MockURLSession(completionHandler: (testInboxMessageContentPayloadData, responseInboxMessageContent, nil))
            DependencyConfiguration.shared.inboxMessageContentURLSession = mockSessionInboxMessageContent

            CordialInboxMessageAPI().fetchInboxMessageContent(mcID: self.testMcID, onSuccess: { content in
                
                if let content = CoreDataManager.shared.inboxMessagesContent.getInboxMessageContentFromCoreData(mcID: self.testMcID),
                   content != self.testInboxMessageContentPayload {
                    
                    isVerified = true
                    XCTAssert(true)
                } else {
                    XCTAssert(false)
                }
            }, onFailure: { error in
                XCTAssert(false, error)
            })
        }
    
        XCTAssert(isVerified)
    }
    
    func testInboxMessageContentCache() {
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        var isVerified = false

        if let testInboxMessagePayloadData = self.testInboxMessagePayload.data(using: .utf8),
           let testInboxMessageContentPayloadData = self.testInboxMessageContentPayload.data(using: .utf8),
           let url = URL(string: self.validStringURL) {

            let responseInboxMessage = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            let mockSessionInboxMessage = MockURLSession(completionHandler: (testInboxMessagePayloadData, responseInboxMessage, nil))
            DependencyConfiguration.shared.inboxMessageURLSession = mockSessionInboxMessage
            
            let responseInboxMessageContent = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            let mockSessionInboxMessageContent = MockURLSession(completionHandler: (testInboxMessageContentPayloadData, responseInboxMessageContent, nil))
            DependencyConfiguration.shared.inboxMessageContentURLSession = mockSessionInboxMessageContent

            CordialInboxMessageAPI().fetchInboxMessageContent(mcID: self.testMcID, onSuccess: { content in
                
                if let content = CoreDataManager.shared.inboxMessagesContent.getInboxMessageContentFromCoreData(mcID: self.testMcID),
                   content == self.testInboxMessageContentPayload {
                    
                    isVerified = true
                    XCTAssert(true)
                } else {
                    XCTAssert(false)
                }
            }, onFailure: { error in
                XCTAssert(false, error)
            })
        }
        
        XCTAssert(isVerified)
    }
    
    func testInboxMessageContent403Status() {
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        var isVerified = false

        if let testInboxMessagePayloadData = self.testInboxMessagePayload.data(using: .utf8),
           let testInboxMessageContentPayloadData = self.testInboxMessageContentPayload.data(using: .utf8),
           let url = URL(string: self.validStringURL) {

            let responseInboxMessage = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            let mockSessionInboxMessage = MockURLSession(completionHandler: (testInboxMessagePayloadData, responseInboxMessage, nil))
            DependencyConfiguration.shared.inboxMessageURLSession = mockSessionInboxMessage
            
            let responseInboxMessageContent = HTTPURLResponse(url: url, statusCode: 403, httpVersion: nil, headerFields: nil)
            let mockSessionInboxMessageContent = MockURLSession(completionHandler: (testInboxMessageContentPayloadData, responseInboxMessageContent, nil))
            DependencyConfiguration.shared.inboxMessageContentURLSession = mockSessionInboxMessageContent

            CordialInboxMessageAPI().fetchInboxMessageContent(mcID: self.testMcID, onSuccess: { content in
                XCTAssert(false)
            }, onFailure: { error in
                if InboxMessageContentGetter.shared.is403StatusReceived {
                    isVerified = true
                    XCTAssert(true)
                } else {
                    XCTAssert(false)
                }
            })
        }
        
        XCTAssert(isVerified)
    }
    
    func testInboxMessageContent500Status() {
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        var isVerified = false

        if let testInboxMessagePayloadData = self.testInboxMessagePayload.data(using: .utf8),
           let testInboxMessageContentPayloadData = self.testInboxMessageContentPayload.data(using: .utf8),
           let url = URL(string: self.validStringURL) {

            let responseInboxMessage = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            let mockSessionInboxMessage = MockURLSession(completionHandler: (testInboxMessagePayloadData, responseInboxMessage, nil))
            DependencyConfiguration.shared.inboxMessageURLSession = mockSessionInboxMessage
            
            let responseInboxMessageContent = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
            let mockSessionInboxMessageContent = MockURLSession(completionHandler: (testInboxMessageContentPayloadData, responseInboxMessageContent, nil))
            DependencyConfiguration.shared.inboxMessageContentURLSession = mockSessionInboxMessageContent

            CordialInboxMessageAPI().fetchInboxMessageContent(mcID: self.testMcID, onSuccess: { content in
                XCTAssert(false)
            }, onFailure: { error in
                if !InboxMessageContentGetter.shared.is403StatusReceived {
                    isVerified = true
                    XCTAssert(true)
                } else {
                    XCTAssert(false)
                }
            })
        }
        
        XCTAssert(isVerified)
    }
    
    func testInboxMessagesMarkRead() {
        let mock = MockRequestSenderInboxMessagesMarkReadUnread()

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()

        CordialInboxMessageAPI().markInboxMessagesRead(mcIDs: [self.testMcID])
        
        XCTAssert(mock.isVerified)
    }
    
    func testInboxMessagesMarkUnread() {
        let mock = MockRequestSenderInboxMessagesMarkReadUnread()

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()

        CordialInboxMessageAPI().markInboxMessagesUnread(mcIDs: [self.testMcID])
        
        XCTAssert(mock.isVerified)
    }
    
    func testInboxMessagesMarkReadInvalidMcID() {
        let mock = MockRequestSenderInboxMessagesMarkReadInvalidMcID()
        
        let invalidMcID = "\(self.testMcID)_invalid"
        mock.invalidMcID = invalidMcID
        
        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()

        let mcIDs = [invalidMcID, self.testMcID]
        CordialInboxMessageAPI().markInboxMessagesRead(mcIDs: mcIDs)
        
        XCTAssert(mock.isVerified)
    }
    
    func testInboxMessagesMarkUnreadInvalidMcID() {
        let mock = MockRequestSenderInboxMessagesMarkUnreadInvalidMcID()
        
        let invalidMcID = "\(self.testMcID)_invalid"
        mock.invalidMcID = invalidMcID
        
        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()

        let mcIDs = [invalidMcID, self.testMcID]
        CordialInboxMessageAPI().markInboxMessagesUnread(mcIDs: mcIDs)
        
        XCTAssert(mock.isVerified)
    }
    
    func testInboxMessagesMarkReadCache() {
        let mock = MockRequestSenderInboxMessagesMarkReadCache()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        let markAsReadMcIDs_1 = ["\(self.testMcID)_1", "\(self.testMcID)_2"]
        let markAsReadMcIDs_2 = ["\(self.testMcID)_3", "\(self.testMcID)_4"]
        
        let inboxMessagesMarkReadRequest_1 = InboxMessagesMarkReadUnreadRequest(markAsReadMcIDs: markAsReadMcIDs_1, markAsUnreadMcIDs: [])
        CoreDataManager.shared.inboxMessagesMarkReadUnread.putInboxMessagesMarkReadUnreadDataToCoreData(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadRequest_1)

        let inboxMessagesMarkReadRequest_2 = InboxMessagesMarkReadUnreadRequest(markAsReadMcIDs: markAsReadMcIDs_2, markAsUnreadMcIDs: [])
        CoreDataManager.shared.inboxMessagesMarkReadUnread.putInboxMessagesMarkReadUnreadDataToCoreData(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadRequest_2)
        
        self.testCase.reachabilitySenderMakeAllNeededHTTPCalls()
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testInboxMessagesMarkUnreadCache() {
        let mock = MockRequestSenderInboxMessagesMarkUnreadCache()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        let markAsUnreadMcIDs_1 = ["\(self.testMcID)_1", "\(self.testMcID)_2"]
        let markAsUnreadMcIDs_2 = ["\(self.testMcID)_3", "\(self.testMcID)_4"]
        
        let inboxMessagesMarkUnreadRequest_1 = InboxMessagesMarkReadUnreadRequest(markAsReadMcIDs: [], markAsUnreadMcIDs: markAsUnreadMcIDs_1)
        CoreDataManager.shared.inboxMessagesMarkReadUnread.putInboxMessagesMarkReadUnreadDataToCoreData(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkUnreadRequest_1)

        let inboxMessagesMarkUnreadRequest_2 = InboxMessagesMarkReadUnreadRequest(markAsReadMcIDs: [], markAsUnreadMcIDs: markAsUnreadMcIDs_2)
        CoreDataManager.shared.inboxMessagesMarkReadUnread.putInboxMessagesMarkReadUnreadDataToCoreData(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkUnreadRequest_2)
        
        self.testCase.reachabilitySenderMakeAllNeededHTTPCalls()
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testInboxMessageDelete() {
        let mock = MockRequestSenderInboxMessageDelete()
        
        mock.contactKey = self.testPrimaryKey
        mock.mcID = self.testMcID
        
        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        let inboxMessage = InboxMessage(mcID: self.testMcID, url: String(), urlExpireAt: Date(), isRead: true, sentAt: Date(), metadata: String())
        CoreDataManager.shared.inboxMessagesCache.putInboxMessageToCoreData(inboxMessage: inboxMessage)
        CoreDataManager.shared.inboxMessagesContent.putInboxMessageContentToCoreData(mcID: self.testMcID, content: self.testInboxMessageContentPayload)
        
        CordialInboxMessageAPI().deleteInboxMessage(mcID: self.testMcID)
        
        if CoreDataManager.shared.inboxMessagesCache.getInboxMessageFromCoreData(mcID: self.testMcID) == nil,
           CoreDataManager.shared.inboxMessagesContent.getInboxMessageContentFromCoreData(mcID: self.testMcID) == nil,
           mock.isVerified {
            
            XCTAssert(true)
        }
    }
    
    func testInboxMessageDelegate() {
        let inboxMessageHandler = InboxMessageHandler()
        inboxMessageHandler.testMcID = self.testMcID
        
        CordialApiConfiguration.shared.inboxMessageDelegate = inboxMessageHandler

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()

        if let testSilentNotificationData = self.testSilentNotification.data(using: .utf8),
            let userInfo = try? JSONSerialization.jsonObject(with: testSilentNotificationData, options: []) as? [AnyHashable : Any] {

            CordialSwizzlerHelper().didReceiveRemoteNotification(userInfo: userInfo)
        }

        XCTAssert(inboxMessageHandler.isVerified)
    }
    
    func testInboxMessageReadEvent() {
        let mock = MockRequestSenderInboxMessageReadEvent()
         
        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        CordialInboxMessageAPI().sendInboxMessageReadEvent(mcID: self.testMcID)
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testInboxMessageMaxCacheSize() {
        var isVerified = false
        
        CordialApiConfiguration.shared.inboxMessageCache.maxCacheSize = self.testInboxMessageContentPayload.data(using: .utf8)!.count - 1
        
        CoreDataManager.shared.inboxMessagesContent.putInboxMessageContentToCoreData(mcID: self.testMcID, content: self.testInboxMessageContentPayload)
        
        if CoreDataManager.shared.inboxMessagesContent.getInboxMessageContentFromCoreData(mcID: self.testMcID) == nil {
            isVerified = true
        }
        
        XCTAssert(isVerified)
    }
    
    func testInboxMessageMaxCachableMessageSize() {
        var isVerified = false
        
        CordialApiConfiguration.shared.inboxMessageCache.maxCachableMessageSize = self.testInboxMessageContentPayload.data(using: .utf8)!.count + 1
        
        CoreDataManager.shared.inboxMessagesContent.putInboxMessageContentToCoreData(mcID: self.testMcID, content: self.testInboxMessageContentPayload)
        CoreDataManager.shared.inboxMessagesContent.putInboxMessageContentToCoreData(mcID: "\(self.testMcID)_2", content: "\(self.testInboxMessageContentPayload)_2")
        
        if CoreDataManager.shared.inboxMessagesContent.getInboxMessageContentFromCoreData(mcID: self.testMcID) == self.testInboxMessageContentPayload,
           CoreDataManager.shared.inboxMessagesContent.getInboxMessageContentFromCoreData(mcID: "\(self.testMcID)_2") == nil {
            
            isVerified = true
        }
        
        XCTAssert(isVerified)
    }
    
    func testInboxMessageMaxCacheSizeAndMaxCachableMessageSize() {
        var isVerified = false
        
        CordialApiConfiguration.shared.inboxMessageCache.maxCacheSize = (self.testInboxMessageContentPayload.data(using: .utf8)!.count + 1) * 2
        CordialApiConfiguration.shared.inboxMessageCache.maxCachableMessageSize = self.testInboxMessageContentPayload.data(using: .utf8)!.count + 1
        
        CoreDataManager.shared.inboxMessagesContent.putInboxMessageContentToCoreData(mcID: self.testMcID, content: self.testInboxMessageContentPayload)
        CoreDataManager.shared.inboxMessagesContent.putInboxMessageContentToCoreData(mcID: "\(self.testMcID)_2", content: self.testInboxMessageContentPayload)
        CoreDataManager.shared.inboxMessagesContent.putInboxMessageContentToCoreData(mcID: "\(self.testMcID)_3", content: self.testInboxMessageContentPayload)
        CoreDataManager.shared.inboxMessagesContent.putInboxMessageContentToCoreData(mcID: "\(self.testMcID)_4", content: self.testInboxMessageContentPayload)
        
        if CoreDataManager.shared.inboxMessagesContent.getInboxMessageContentFromCoreData(mcID: self.testMcID) == nil,
           CoreDataManager.shared.inboxMessagesContent.getInboxMessageContentFromCoreData(mcID: "\(self.testMcID)_2") == self.testInboxMessageContentPayload,
           CoreDataManager.shared.inboxMessagesContent.getInboxMessageContentFromCoreData(mcID: "\(self.testMcID)_3") == self.testInboxMessageContentPayload,
           CoreDataManager.shared.inboxMessagesContent.getInboxMessageContentFromCoreData(mcID: "\(self.testMcID)_4") == self.testInboxMessageContentPayload {
            
            isVerified = true
        }
        
        XCTAssert(isVerified)
    }
    
    func testAppDelegateEmailDeepLinks() {
        self.testCase.swizzleAppAndSceneDelegateMethods()
        
        // DeepLink Mock
        let mock = MockRequestSenderEmailDeepLinkHasBeenOpen()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        // Email DeepLink Mock
        let headerFields = [
            "Location": self.testDeepLinkURL,
            "x-mcid": self.testMcID
        ]
        
        if let emailDeepLinkPayloadData = String().data(using: .utf8),
           let url = URL(string: self.validStringURL) {
            
            let response = HTTPURLResponse(url: url, statusCode: 302, httpVersion: nil, headerFields: headerFields)
            let mockSession = MockURLSession(completionHandler: (emailDeepLinkPayloadData, response, nil))
            
            DependencyConfiguration.shared.emailDeepLinkURLSession = mockSession
        }
        
        // DeepLink Click
        let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        userActivity.webpageURL = URL(string: self.testEmailDeepLinkURL)
        
        self.testCase.processAppDelegateUniversalLinks(userActivity: userActivity)
        self.testCase.appMovedFromBackground()
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    @available(iOS 13.0, *)
    func testSceneDelegateEmailDeepLinks() {
        self.testCase.swizzleAppAndSceneDelegateMethods()
        
        // DeepLink Mock
        let mock = MockRequestSenderEmailDeepLinkHasBeenOpen()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        // Email DeepLink Mock
        let headerFields = [
            "Location": self.testDeepLinkURL,
            "x-mcid": self.testMcID
        ]
        
        if let emailDeepLinkPayloadData = String().data(using: .utf8),
           let url = URL(string: self.validStringURL) {
            
            let response = HTTPURLResponse(url: url, statusCode: 302, httpVersion: nil, headerFields: headerFields)
            let mockSession = MockURLSession(completionHandler: (emailDeepLinkPayloadData, response, nil))
            
            DependencyConfiguration.shared.emailDeepLinkURLSession = mockSession
        }
        
        // DeepLink Click
        let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        userActivity.webpageURL = URL(string: self.testEmailDeepLinkURL)
        
        self.testCase.processSceneDelegateUniversalLinks(userActivity: userActivity)
        self.testCase.appMovedFromBackground()
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    @available(iOS 13.0, *)
    func testSceneDelegateEmailDeepLinksTestClickNotSaveMcID() {
        self.testCase.swizzleAppAndSceneDelegateMethods()
        
        // DeepLink Mock
        let mock = MockRequestSenderTestEmailDeepLinksNotSaveMcID()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        // Email DeepLink Mock
        let headerFields = [
            "Location": self.testDeepLinkURL,
            "x-mcid": self.testMcID,
            "x-message-istest": "1"
        ]
        
        if let emailDeepLinkPayloadData = String().data(using: .utf8),
           let url = URL(string: self.validStringURL) {
            
            let response = HTTPURLResponse(url: url, statusCode: 302, httpVersion: nil, headerFields: headerFields)
            let mockSession = MockURLSession(completionHandler: (emailDeepLinkPayloadData, response, nil))
            
            DependencyConfiguration.shared.emailDeepLinkURLSession = mockSession
        }
        
        // DeepLink Click
        let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        userActivity.webpageURL = URL(string: self.testEmailDeepLinkURL)
        
        self.testCase.processSceneDelegateUniversalLinks(userActivity: userActivity)
        self.testCase.appMovedFromBackground()
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    @available(iOS 13.0, *)
    func testSceneDelegateEmailDeepLinksNotVanityDomain() {
        self.testCase.swizzleAppAndSceneDelegateMethods()
        
        // DeepLinkDelegate Mock
        let mock = MockEmailDeepLinkDelegateNotVanityDomain()
        CordialApiConfiguration.shared.cordialDeepLinksDelegate = mock

        // DeepLink Mock
        DependencyConfiguration.shared.requestSender = EmptyMockRequestSender()

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()

        // Email DeepLink Mock
        let headerFields = [
            "Location": self.testDeepLinkURL,
            "x-mcid": self.testMcID
        ]

        if let emailDeepLinkPayloadData = String().data(using: .utf8),
           let url = URL(string: self.validStringURL) {

            let response = HTTPURLResponse(url: url, statusCode: 302, httpVersion: nil, headerFields: headerFields)
            let mockSession = MockURLSession(completionHandler: (emailDeepLinkPayloadData, response, nil))

            DependencyConfiguration.shared.emailDeepLinkURLSession = mockSession
        }

        // DeepLink Click
        let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        userActivity.webpageURL = URL(string: self.validStringURL)

        self.testCase.processSceneDelegateUniversalLinks(userActivity: userActivity)
        self.testCase.appMovedFromBackground()

        let expectation = XCTestExpectation(description: "Expectation for sending request")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)
    }
    
    @available(iOS 13.0, *)
    func testSceneDelegateEmailDeepLinksNot302Status() {
        self.testCase.swizzleAppAndSceneDelegateMethods()
        
        // DeepLinkDelegate Mock
        let mock = MockEmailDeepLinkDelegate()
        CordialApiConfiguration.shared.cordialDeepLinksDelegate = mock

        // DeepLink Mock
        DependencyConfiguration.shared.requestSender = EmptyMockRequestSender()

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()

        // Email DeepLink Mock
        if let emailDeepLinkPayloadData = String().data(using: .utf8),
           let url = URL(string: self.validStringURL) {

            let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
            let mockSession = MockURLSession(completionHandler: (emailDeepLinkPayloadData, response, nil))

            DependencyConfiguration.shared.emailDeepLinkURLSession = mockSession
        }

        // DeepLink Click
        let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        userActivity.webpageURL = URL(string: self.testDeepLinkURL)

        self.testCase.processSceneDelegateUniversalLinks(userActivity: userActivity)
        self.testCase.appMovedFromBackground()

        let expectation = XCTestExpectation(description: "Expectation for sending request")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)
    }
    
    @available(iOS 13.0, *)
    func testSceneDelegateSMSDeepLinks() {
        self.testCase.swizzleAppAndSceneDelegateMethods()
        
        // DeepLinkDelegate Mock
        let mock = MockSMSDeepLinkDelegate()
        CordialApiConfiguration.shared.cordialDeepLinksDelegate = mock

        // DeepLink Mock
        DependencyConfiguration.shared.requestSender = EmptyMockRequestSender()
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        // Email DeepLink Mock
        let headerFields = [
            "Location": self.testEmailDeepLinkURL,
            "x-mcid": self.testMcID
        ]
        
        if let emailDeepLinkPayloadData = String().data(using: .utf8),
           let url = URL(string: self.validStringURL) {
            
            let response = HTTPURLResponse(url: url, statusCode: 302, httpVersion: nil, headerFields: headerFields)
            let mockSession = MockURLSession(completionHandler: (emailDeepLinkPayloadData, response, nil))
            
            DependencyConfiguration.shared.emailDeepLinkURLSession = mockSession
        }
        
        // DeepLink Click
        let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        userActivity.webpageURL = URL(string: self.testSMSDeepLinkURL)
        
        self.testCase.processSceneDelegateUniversalLinks(userActivity: userActivity)
        self.testCase.appMovedFromBackground()
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            CordialApiConfiguration.shared.vanityDomains = ["s.cordial.com"]
            
            self.testCase.appMovedFromBackground()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                XCTAssert(mock.isVerified)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testAppDelegateURLSchemesDeepLinks() {
        self.testCase.swizzleAppAndSceneDelegateMethods()
        
        let mock = MockRequestSenderURLSchemesDeepLinkHasBeenOpen()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
                
        self.testCase.processAppDelegateURLSchemes(url: URL(string: self.testDeepLinkURL)!)
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    @available(iOS 13.0, *)
    func testSceneDelegateURLSchemesDeepLinks() {
        self.testCase.swizzleAppAndSceneDelegateMethods()
        
        let mock = MockRequestSenderURLSchemesDeepLinkHasBeenOpen()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        self.testCase.processSceneDelegateURLSchemes(url: URL(string: self.testDeepLinkURL)!)
        
        let expectation = XCTestExpectation(description: "Expectation for sending request")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(mock.isVerified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
}

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
    let testContactAttributes = ["firstName": "John", "lastName": "Doe"]
    var testPushNotification = String()
    let testDeepLinkURL = "https://tjs.cordialdev.com/prep-tj1.html"
    let testDeepLinkFallbackURL = "https://tjs.cordialdev.com/prep-tj2.html"
    
    override func setUp() {
        self.testCase.clearAllTestCaseData()
        
        CordialApiConfiguration.shared.initialize(accountKey: "qc-all-channels", channelKey: "push")
        CordialApiConfiguration.shared.osLogManager.setOSLogLevel(.none)
        CordialApiConfiguration.shared.pushNotificationHandler = PushNotificationHandler()
        CordialApiConfiguration.shared.cordialDeepLinksHandler = DeepLinksHandler()
        
        self.testPushNotification = """
            {
                "aps":{
                    "alert":"Text push notification message."
                },
                "mcID": "\(self.testMcId)",
                "deepLink": {
                    "url": "\(self.testDeepLinkURL)",
                    "fallbackUrl": "\(self.testDeepLinkFallbackURL)"
                }
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
        
        XCTAssert(mock.isVerified)
    }
    
    func testRemoteNotificationsHasBeenTapped() {
        let mock = MockRequestSenderRemoteNotificationsHasBeenTapped()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        if let testPushNotificationData = self.testPushNotification.data(using: .utf8), let userInfo = try? JSONSerialization.jsonObject(with: testPushNotificationData, options: []) as? [AnyHashable : Any] {
            CordialPushNotificationHelper().pushNotificationHasBeenTapped(userInfo: userInfo)
        }
        
        XCTAssert(mock.isVerified)
    }
    
    func testRemoteNotificationsHasBeenForegroundDelivered() {
        let mock = MockRequestSenderRemoteNotificationsHasBeenForegroundDelivered()

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()

        if let testPushNotificationData = self.testPushNotification.data(using: .utf8), let userInfo = try? JSONSerialization.jsonObject(with: testPushNotificationData, options: []) as? [AnyHashable : Any] {
            CordialPushNotificationHelper().pushNotificationHasBeenForegroundDelivered(userInfo: userInfo)
        }

        XCTAssert(mock.isVerified)
    }
    
    func testRemoteNotificationsHasBeenTappedWithDeepLink() {
        let mock = MockRequestSenderRemoteNotificationsHasBeenTappedWithDeepLink()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        if let testPushNotificationData = self.testPushNotification.data(using: .utf8), let userInfo = try? JSONSerialization.jsonObject(with: testPushNotificationData, options: []) as? [AnyHashable : Any] {
            CordialPushNotificationHelper().pushNotificationHasBeenTapped(userInfo: userInfo)
        }
        
        XCTAssert(mock.isVerified)
    }
    
    func testRemoteNotificationsHasBeenTappedWithMcId() {
        let mock = MockRequestSenderRemoteNotificationsHasBeenTappedWithMcId()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        if let testPushNotificationData = self.testPushNotification.data(using: .utf8), let userInfo = try? JSONSerialization.jsonObject(with: testPushNotificationData, options: []) as? [AnyHashable : Any] {
            CordialPushNotificationHelper().pushNotificationHasBeenTapped(userInfo: userInfo)
        }
        
        XCTAssert(mock.isVerified)
    }
    
    func testDeepLinkDelegate() {
        let mock = MockPushNotificationHandlerDeepLinkDelegate()
        
        CordialApiConfiguration.shared.cordialDeepLinksHandler = mock
        DependencyConfiguration.shared.requestSender = EmptyMockRequestSender()
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        if let testPushNotificationData = self.testPushNotification.data(using: .utf8), let userInfo = try? JSONSerialization.jsonObject(with: testPushNotificationData, options: []) as? [AnyHashable : Any] {
            CordialPushNotificationHelper().pushNotificationHasBeenTapped(userInfo: userInfo)
        }
        
        XCTAssert(mock.isVerified)
    }
    
    func testSetContact() {
        let mock = MockRequestSenderSetContact()

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        
        self.cordialAPI.setContact(primaryKey: self.testPrimaryKey)
        
        XCTAssert(mock.isVerified)
    }

    func testUpsertContact() {
        let mock = MockRequestSenderUpsertContact()

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        
        self.cordialAPI.upsertContact(attributes: self.testContactAttributes)
        
        XCTAssert(mock.isVerified)
    }
    
    func testUnsetContact() {
        let mock = MockRequestSenderUnsetContact()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        
         self.cordialAPI.unsetContact()
        
        XCTAssert(mock.isVerified)
    }
    
    func testSDKSecurityAbsentJWT() {
        let mock = MockRequestSenderSDKSecurity()

        DependencyConfiguration.shared.requestSender = mock
        
        self.cordialAPI.setContact(primaryKey: self.testPrimaryKey)
        
        XCTAssert(mock.isVerified)
    }
    
    func testSDKSecurityNotValidJWT() {
        let mock = MockRequestSenderSDKSecurity()

        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        
        self.cordialAPI.setContact(primaryKey: self.testPrimaryKey)
        
        XCTAssert(mock.isVerified)
    }
    
    // Guest -> PK
    func testNotClearMcIdIfLoginWithPrimaryKeyInGuestMode() {
        let mock = MockRequestSenderSaveMcIdAfterSetContact()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        InternalCordialAPI().setCurrentMcID(mcID: self.testMcId)
        
        self.cordialAPI.setContact(primaryKey: self.testPrimaryKey)
        
        XCTAssert(mock.isVerified)
    }
    
    // Guest -> Guest
    func testNotClearMcIdIfLoginWithoutPrimaryKeyInGuestMode() {
        let mock = MockRequestSenderSaveMcIdAfterSetContact()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.markUserAsLoggedIn()
        
        InternalCordialAPI().setCurrentMcID(mcID: self.testMcId)
        
        self.cordialAPI.setContact(primaryKey: nil)
        
        XCTAssert(mock.isVerified)
    }
    
    // PK -> PK && PK == PK
    func testNotClearMcIdIfLoginWithTheSamePrimaryKeyInLoginMode() {
        let mock = MockRequestSenderSaveMcIdAfterSetContact()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        InternalCordialAPI().setCurrentMcID(mcID: self.testMcId)
        
        self.cordialAPI.setContact(primaryKey: self.testPrimaryKey)
        
        XCTAssert(mock.isVerified)
    }
    
    // PK -> Guest
    func testClearMcIdIfLoginWithoutPrimaryKeyInLoginMode() {
        let mock = MockRequestSenderNotSaveMcIdAfterSetContact()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        InternalCordialAPI().setCurrentMcID(mcID: self.testMcId)
        
        self.cordialAPI.setContact(primaryKey: nil)
        
        XCTAssert(mock.isVerified)
    }
    
    // PK -> PK && PK != PK
    func testClearMcIdIfLoginWithNotTheSamePrimaryKeyInLoginMode() {
        let mock = MockRequestSenderNotSaveMcIdAfterSetContact()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT(token: self.testJWT)
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        self.testCase.markUserAsLoggedIn()
        
        InternalCordialAPI().setCurrentMcID(mcID: self.testMcId)
        
        self.cordialAPI.setContact(primaryKey: "new_\(self.testPrimaryKey)")
        
        XCTAssert(mock.isVerified)
    }
}

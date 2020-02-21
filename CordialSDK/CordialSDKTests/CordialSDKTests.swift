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
    let testMcId = "test_mc_id"
    let testContactAttributes = ["firstName": "John", "lastName": "Doe"]
    var testPushNotification = String()
    
    override func setUp() {
        self.testCase.clearAllTestCaseData()
        
        CordialApiConfiguration.shared.initialize(accountKey: "qc-all-channels", channelKey: "push")
        CordialApiConfiguration.shared.osLogManager.setOSLogLevel(.none)
        
        self.testPushNotification = """
        {
             "aps":{
                "alert":"Text push notification message."
             },
        "mcID": "\(self.testMcId)"
          }
        """
    }
    
    func testAPNsToken() {
        let mock = MockRequestSenderRemoteNotificationsDeviceToken()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT()
        
        if let deviceToken = Data(base64Encoded: self.testDeviceToken) {
            UIApplication.shared.delegate?.application?(UIApplication.shared, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
        
        XCTAssert(mock.isVerified)
    }
    
    func testRemoteNotificationsHasBeenTapped() {
        let mock = MockRequestSenderRemoteNotificationsHasBeenTapped()
        
        DependencyConfiguration.shared.requestSender = mock
        
        self.testCase.setTestJWT()
        self.testCase.markUserAsLoggedIn()
        
        if let testPushNotificationData = self.testPushNotification.data(using: .utf8), let userInfo = try? JSONSerialization.jsonObject(with: testPushNotificationData, options: []) as? [AnyHashable : Any] {
            CordialPushNotificationHelper().pushNotificationHasBeenTapped(userInfo: userInfo)
        }
        
        XCTAssert(mock.isVerified)
    }
    
    func testRemoteNotificationsHasBeenForegroundDelivered() {
        let mock = MockRequestSenderRemoteNotificationsHasBeenForegroundDelivered()

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT()
        self.testCase.markUserAsLoggedIn()

        if let testPushNotificationData = self.testPushNotification.data(using: .utf8), let userInfo = try? JSONSerialization.jsonObject(with: testPushNotificationData, options: []) as? [AnyHashable : Any] {
            CordialPushNotificationHelper().pushNotificationHasBeenForegroundDelivered(userInfo: userInfo)
        }

        XCTAssert(mock.isVerified)
    }
    
    func testSetContact() {
        let mock = MockRequestSenderSetContact()

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT()
        
        self.cordialAPI.setContact(primaryKey: self.testPrimaryKey)
        
        XCTAssert(mock.isVerified)
    }

    func testUpsertContact() {
        let mock = MockRequestSenderUpsertContact()

        DependencyConfiguration.shared.requestSender = mock

        self.testCase.setTestJWT()
        self.testCase.setContactPrimaryKey(primaryKey: self.testPrimaryKey)
        
        self.cordialAPI.upsertContact(attributes: self.testContactAttributes)
        
        XCTAssert(mock.isVerified)
    }
}

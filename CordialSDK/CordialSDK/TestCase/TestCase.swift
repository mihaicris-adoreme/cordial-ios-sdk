//
//  TestCase.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

@objc public class TestCase: NSObject {
    
    @objc public func clearAllTestCaseData() {
        CoreDataManager.shared.deleteAllCoreData()
        CordialUserDefaults.removeAllData()
    }
    
    @objc public func setTestJWT() {
        InternalCordialAPI().setCurrentJWT(JWT: "testJWT")
    }
    
    @objc public func getPreparedRemoteNotificationsDeviceToken(deviceToken: Data) -> String {
        return InternalCordialAPI().getPreparedRemoteNotificationsDeviceToken(deviceToken: deviceToken)
    }
    
    @objc public func setContactPrimaryKey(primaryKey: String) {
        InternalCordialAPI().setContactPrimaryKey(primaryKey: primaryKey)
    }
    
    @objc public func markUserAsLoggedIn() {
        CordialUserDefaults.set(true, forKey: API.USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN)
    }
    
    @objc public func getPushNotificationDisallowStatus() -> String {
        return API.PUSH_NOTIFICATION_STATUS_DISALLOW
    }
    
    @objc public func getEventNamePushNotificationTap() -> String {
        return API.EVENT_NAME_PUSH_NOTIFICATION_TAP
    }
    
    @objc public func getEventNamePushNotificationForegroundDelivered() -> String {
        return API.EVENT_NAME_PUSH_NOTIFICATION_DELIVERED_FOREGROUND
    }
    
    @objc public func getDeviceIdentifier() -> String {
        return InternalCordialAPI().getDeviceIdentifier()
    }

}

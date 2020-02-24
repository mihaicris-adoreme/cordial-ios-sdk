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
    
    @objc public func setTestJWT(token: String) {
        InternalCordialAPI().setCurrentJWT(JWT: token)
    }
    
    @objc public func getCurrentJWT() -> String? {
        return InternalCordialAPI().getCurrentJWT()
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

    @objc public func emulateUpsertContacts401Status(task: URLSessionDownloadTask) {
        if let operation = CordialURLSession.shared.getOperation(taskIdentifier: task.taskIdentifier), let upsertContactsURLSessionData = operation.taskData as? UpsertContactsURLSessionData, let request = task.originalRequest, let url = request.url, let headerFields = request.allHTTPHeaderFields, let httpResponse = HTTPURLResponse(url: url, statusCode: 401, httpVersion: "HTTP/1.1", headerFields: headerFields), let httpBody = request.httpBody {
            
            let location = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("location.txt")
            do {
                try httpBody.write(to: location, options: .atomic)
                
                UpsertContactsURLSessionManager().completionHandler(upsertContactsURLSessionData: upsertContactsURLSessionData, httpResponse: httpResponse, location: location)
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            self.setTestJWT(token: "testJWT-2")
        }
    }
}

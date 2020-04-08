//
//  TestCase.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

public class TestCase: NSObject {
    
    public func clearAllTestCaseData() {
        CoreDataManager.shared.deleteAllCoreData()
        CordialUserDefaults.removeAllData()
    }
    
    public func setTestJWT(token: String) {
        InternalCordialAPI().setCurrentJWT(JWT: token)
    }
    
    public func getCurrentJWT() -> String? {
        return InternalCordialAPI().getCurrentJWT()
    }
    
    public func getPreparedRemoteNotificationsDeviceToken(deviceToken: Data) -> String {
        return InternalCordialAPI().getPreparedRemoteNotificationsDeviceToken(deviceToken: deviceToken)
    }
    
    public func setContactPrimaryKey(primaryKey: String) {
        InternalCordialAPI().setContactPrimaryKey(primaryKey: primaryKey)
    }
    
    public func markUserAsLoggedIn() {
        CordialUserDefaults.set(true, forKey: API.USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN)
    }
    
    public func getPushNotificationDisallowStatus() -> String {
        return API.PUSH_NOTIFICATION_STATUS_DISALLOW
    }
    
    public func getEventNamePushNotificationTap() -> String {
        return API.EVENT_NAME_PUSH_NOTIFICATION_TAP
    }
    
    public func getEventNamePushNotificationForegroundDelivered() -> String {
        return API.EVENT_NAME_PUSH_NOTIFICATION_DELIVERED_FOREGROUND
    }
    
    public func getEventNameDeepLinkOpen() -> String {
        return API.EVENT_NAME_DEEP_LINK_OPEN
    }
    
    public func getEventNameAppMovedToBackground() -> String {
        return API.EVENT_NAME_APP_MOVED_TO_BACKGROUND
    }
    
    public func getDeviceIdentifier() -> String {
        return InternalCordialAPI().getDeviceIdentifier()
    }

    public func notValidJWT(task: URLSessionDownloadTask) {
        if let operation = CordialURLSession.shared.getOperation(taskIdentifier: task.taskIdentifier) {
            switch operation.taskName {
            case API.DOWNLOAD_TASK_NAME_SDK_SECURITY_GET_JWT:
                self.setTestJWT(token: "testJWT-2")
                
                SDKSecurity.shared.isCurrentlyFetchingJWT = false
                
            case API.DOWNLOAD_TASK_NAME_UPSERT_CONTACTS:
                if let upsertContactsURLSessionData = operation.taskData as? UpsertContactsURLSessionData, let request = task.originalRequest, let url = request.url, let headerFields = request.allHTTPHeaderFields, let httpResponse = HTTPURLResponse(url: url, statusCode: 401, httpVersion: "HTTP/1.1", headerFields: headerFields), let httpBody = request.httpBody {
                    
                    let location = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("location.txt")
                    do {
                        try httpBody.write(to: location, options: .atomic)
                        
                        UpsertContactsURLSessionManager().completionHandler(upsertContactsURLSessionData: upsertContactsURLSessionData, httpResponse: httpResponse, location: location)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            default: break
            }
        }
    }
    
    public func appMovedToBackground() {
        NotificationManager.shared.appMovedToBackground()
    }
    
    public func reachabilitySenderMakeAllNeededHTTPCalls() {
        ReachabilitySender.shared.makeAllNeededHTTPCalls()
    }
    
    public func sendCachedCustomEventRequests(reason: String) {
        CoreDataManager.shared.coreDataSender.sendCachedCustomEventRequests(reason: reason)
    }
}

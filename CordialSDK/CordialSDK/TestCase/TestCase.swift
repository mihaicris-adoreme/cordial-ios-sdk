//
//  TestCase.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

public class TestCase {
    
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
    
    public func getPushNotificationStatus() -> String? {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS)
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
        NotificationManager.shared.appMovedToBackgroundProceed()
    }
    
    public func reachabilitySenderMakeAllNeededHTTPCalls() {
        ReachabilitySender.shared.makeAllNeededHTTPCalls()
    }

    public func sendInvalidEventRequest(task: URLSessionDownloadTask, invalidEventName: String) {
        if let operation = CordialURLSession.shared.getOperation(taskIdentifier: task.taskIdentifier) {
            switch operation.taskName {
            case API.DOWNLOAD_TASK_NAME_SEND_CUSTOM_EVENTS:
                if let sendCustomEventsURLSessionData = operation.taskData as? SendCustomEventsURLSessionData, let request = task.originalRequest, let url = request.url, let headerFields = request.allHTTPHeaderFields, let httpResponse422 = HTTPURLResponse(url: url, statusCode: 422, httpVersion: "HTTP/1.1", headerFields: headerFields), let httpResponse200 = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headerFields), let httpBody = request.httpBody {
                    
                    let location = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("location.txt")
                    do {
                        if self.isHttpBodyHasInvalidEventName(httpBody: httpBody, invalidEventName: invalidEventName), let invalidHttpBody = self.getMockedInvalidHttpBody() {
                            try invalidHttpBody.write(to: location, options: .atomic)
                            SendCustomEventsURLSessionManager().completionHandler(sendCustomEventsURLSessionData: sendCustomEventsURLSessionData, httpResponse: httpResponse422, location: location)
                        } else {
                            try httpBody.write(to: location, options: .atomic)
                            SendCustomEventsURLSessionManager().completionHandler(sendCustomEventsURLSessionData: sendCustomEventsURLSessionData, httpResponse: httpResponse200, location: location)
                        }
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            default: break
            }
        }
    }
    
    private func isHttpBodyHasInvalidEventName(httpBody: Data, invalidEventName: String) -> Bool {
        let jsonString = String(decoding: httpBody, as: UTF8.self)
        
        var returnValue = false
        if jsonString.contains(invalidEventName) {
              returnValue = true
          }
        
        return returnValue
    }
    
    private func getMockedInvalidHttpBody() -> Data? {
        return """
            {
              "success": false,
              "error": {
                "code": 422,
                "message": "The given data was invalid.",
                "errors": {
                  "0.deviceId": [
                    "The 0.deviceId field is required."
                  ],
                  "0.event": [
                    "The 0.event field is required."
                  ]
                }
              }
            }
        """.data(using: .utf8)
    }
    
    public func setContactCartRequestToCoreData(cartItems: [CartItem]) {
        let upsertContactCartRequest = UpsertContactCartRequest(cartItems: cartItems)
        CoreDataManager.shared.contactCartRequest.setContactCartRequestToCoreData(upsertContactCartRequest: upsertContactCartRequest)
    }
    
    public func setContactOrderRequestToCoreData(order: Order) {
        let sendContactOrderRequest = SendContactOrderRequest(mcID: nil, order: order)
        CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: [sendContactOrderRequest])
    }
    
    public func getUserAgent() -> String {
        return UserAgentBuilder().getUserAgent()
    }
}

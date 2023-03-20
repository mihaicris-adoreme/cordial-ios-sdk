//
//  TestCase.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit

public class TestCase {
    
    public func clearAllTestCaseData() {
        CoreDataManager.shared.deleteAllCoreData()
        CordialUserDefaults.removeAllData()
    }
    
    public func setTestPushNotificationToken(token: String) {
        InternalCordialAPI().setPushNotificationToken(token: token)
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
    
    public func getEventNameInboxMessageRead() -> String {
        return API.EVENT_NAME_INBOX_MESSAGE_READ
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
                if let upsertContactsURLSessionData = operation.taskData as? UpsertContactsURLSessionData {
                    
                    let responseBody = String()
                    let statusCode = 401
                    
                    UpsertContactsURLSessionManager().completionHandler(upsertContactsURLSessionData: upsertContactsURLSessionData, statusCode: statusCode, responseBody: responseBody)
                }
            default: break
            }
        }
    }
    
    public func appMovedToBackground() {
        NotificationManager.shared.appMovedToBackgroundProceed()
    }
    
    public func appMovedFromBackground() {
        NotificationManager.shared.appMovedFromBackgroundProceed()
    }
    
    public func reachabilitySenderMakeAllNeededHTTPCalls() {
        ReachabilitySender.shared.makeAllNeededHTTPCalls()
    }
    
    public func prepareCurrentPushNotificationStatus() {
        PushNotificationHelper().prepareCurrentPushNotificationStatus()
    }

    public func sendInvalidCustomEventRequest(task: URLSessionDownloadTask) {
        if let operation = CordialURLSession.shared.getOperation(taskIdentifier: task.taskIdentifier) {
            switch operation.taskName {
            case API.DOWNLOAD_TASK_NAME_SEND_CUSTOM_EVENTS:
                if let sendCustomEventsURLSessionData = operation.taskData as? SendCustomEventsURLSessionData {
                    let responseBody = """
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
                            """
                    let statusCode = 422
                    
                    SendCustomEventsURLSessionManager().completionHandler(sendCustomEventsURLSessionData: sendCustomEventsURLSessionData, statusCode: statusCode, responseBody: responseBody)
                }
            default: break
            }
        }
    }
    
    public func sendInvalidInboxMessagesMarkReadUnreadRequest(type: String, mcID: String, task: URLSessionDownloadTask) {
        if let operation = CordialURLSession.shared.getOperation(taskIdentifier: task.taskIdentifier) {
            switch operation.taskName {
            case API.DOWNLOAD_TASK_NAME_INBOX_MESSAGES_READ_UNREAD_MARKS:
                if let inboxMessagesMarkReadUnreadURLSessionData = operation.taskData as? InboxMessagesMarkReadUnreadURLSessionData {
                    
                    let responseBody = """
                                {
                                  "success": false,
                                  "error": {
                                    "code": 422,
                                    "message": "The given data was invalid.",
                                    "errors": {
                                      "\(type).0": [
                                        "Unable to decrypt a mcID value from \(mcID)."
                                      ]
                                    }
                                  }
                                }
                           """
                    let statusCode = 422
                    
                    InboxMessagesMarkReadUnreadURLSessionManager().completionHandler(inboxMessagesMarkReadUnreadURLSessionData: inboxMessagesMarkReadUnreadURLSessionData, statusCode: statusCode, responseBody: responseBody)
                }
            default: break
            }
        }
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
    
    public func sendInAppMessageDataFetchRequestSilentPushes(task: URLSessionDownloadTask) {
        if let operation = CordialURLSession.shared.getOperation(taskIdentifier: task.taskIdentifier) {
            switch operation.taskName {
            case API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE:
                if let inAppMessageURLSessionData = operation.taskData as? InAppMessageURLSessionData {
                    
                    let responseBody = "{ \"content\": \"Hello, I am IAM!\" }"
                    let statusCode = 200
                    
                    FetchInAppMessageURLSessionManager().completionHandler(inAppMessageURLSessionData: inAppMessageURLSessionData, statusCode: statusCode, responseBody: responseBody)
                }
            default: break
            }
        }
    }
    
    public func sendInAppMessagesDataFetchRequestDirectDelivery(task: URLSessionDownloadTask) {
        if let operation = CordialURLSession.shared.getOperation(taskIdentifier: task.taskIdentifier) {
            switch operation.taskName {
            case API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGES:
                let responseBody = """
                        {
                            "messages": [
                                {
                                    "sentAt": "\(CordialDateFormatter().getCurrentTimestamp())",
                                    "_id": "test_mc_id",
                                    "inactiveSessionDisplay": "show-in-app",
                                    "expirationTime": "\(CordialDateFormatter().getTimestampFromDate(date: Date().addingTimeInterval(TimeInterval(60)))))",
                                    "url": "https://cordial.com/in-app-message-content/",
                                    "urlExpireAt": "\(CordialDateFormatter().getTimestampFromDate(date: Date().addingTimeInterval(TimeInterval(60))))"
                                }
                            ]
                        }
                    """
                let statusCode = 200
                
                InAppMessagesURLSessionManager().completionHandler(statusCode: statusCode, responseBody: responseBody)
                
            default: break
            }
        }
    }
    
    public func sendInAppMessageContentDataFetchRequestDirectDelivery(task: URLSessionDownloadTask) {
        if let operation = CordialURLSession.shared.getOperation(taskIdentifier: task.taskIdentifier) {
            switch operation.taskName {
            case API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE_CONTENT:
                if let inAppMessageContentURLSessionData = operation.taskData as? InAppMessageContentURLSessionData {

                    let responseBody = "{ \"content\": \"Hello, I am IAM!\" }"
                    let statusCode = 200
                    
                    InAppMessageContentURLSessionManager().completionHandler(inAppMessageContentURLSessionData: inAppMessageContentURLSessionData, statusCode: statusCode, responseBody: responseBody)
                }
            default: break
            }
        }
    }
    
    public func getContactsURL() -> URL? {
        return URL(string: CordialApiEndpoints().getContactsURL())
    }
    
    public func getInAppMessageURL(mcID: String) -> URL? {
        return URL(string: CordialApiEndpoints().getInAppMessageURL(mcID: mcID))
    }
    
    public func getInboxMessagesURL(contactKey: String) -> URL? {
        return URL(string: CordialApiEndpoints().getInAppMessagesURL(contactKey: contactKey))
    }
    
    public func getEventNameInAppMessageShown() -> String {
        return API.EVENT_NAME_IN_APP_MESSAGE_WAS_SHOWN
    }
    
    public func getEventNameInAppMessageAutoRemove() -> String {
        return API.EVENT_NAME_AUTO_REMOVE_IN_APP_MESSAGE
    }
    
    public func getEventNameInAppMessageManualRemove() -> String {
        return API.EVENT_NAME_MANUAL_REMOVE_IN_APP_MESSAGE
    }
    
    public func getInboxMessagesMarkReadUnreadURL() -> URL? {
        return URL(string: CordialApiEndpoints().getInboxMessagesMarkReadUnreadURL())
    }
    
    public func getInboxMessageURL(contactKey: String, mcID: String) -> URL? {
        return URL(string: CordialApiEndpoints().getInboxMessageURL(contactKey: contactKey, mcID: mcID))
    }
    
    public func swizzleAppAndSceneDelegateMethods() {
        CordialSwizzler.shared.swizzleAppAndSceneDelegateMethods()
    }
    
    public func processAppDelegateUniversalLinks(userActivity: NSUserActivity) {
        let _ = CordialSwizzler.shared.application(UIApplication.shared, continue: userActivity, restorationHandler: { _ in })
    }

    @available(iOS 13.0, *)
    public func processSceneDelegateUniversalLinks(userActivity: NSUserActivity) {
        CordialSwizzler.shared.scene(UIApplication.shared.connectedScenes.first!, continue: userActivity)
    }
    
    public func processAppDelegateURLSchemes(url: URL) {
        let _ = CordialSwizzler.shared.application(UIApplication.shared, open: url)
    }
    
    @available(iOS 13.0, *)
    public func processSceneDelegateURLSchemes(url: URL) {
        InternalCordialAPI().openDeepLink(url: url)
    }
}

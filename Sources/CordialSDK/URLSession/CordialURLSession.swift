//
//  CordialURLSession.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/16/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class CordialURLSession: NSObject, URLSessionDownloadDelegate, URLSessionDelegate {
    
    static var shared = CordialURLSession()
    
    private override init() {}
    
    var backgroundCompletionHandler: (() -> Void)?
    
    private var operations = [Int: CordialURLSessionData]()
    
    private let queue = DispatchQueue(label: "CordialSDKBackgroundURLSessionThreadQueue", attributes: .concurrent)
    
    lazy var backgroundURLSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: API.BACKGROUND_URL_SESSION_IDENTIFIER)
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    // MARK: Background URL session thread queue
    
    func setOperation(taskIdentifier: Int, data: CordialURLSessionData) {
        self.queue.sync(flags: .barrier) {
            self.operations[taskIdentifier] = data
        }
    }
    
    func removeOperation(taskIdentifier: Int) {
        self.queue.sync(flags: .barrier) {
            let _ = self.operations.removeValue(forKey: taskIdentifier)
        }
    }
    
    func getOperation(taskIdentifier: Int) -> CordialURLSessionData? {
        self.queue.sync() {
            return self.operations[taskIdentifier]
        }
    }
    
    // MARK: URLSessionDelegate
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            guard let backgroundCompletionHandler = self.backgroundCompletionHandler else { return }
            backgroundCompletionHandler()
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error, let operation = self.getOperation(taskIdentifier: task.taskIdentifier) {
            DispatchQueue.main.async {
                switch operation.taskName {
                case API.DOWNLOAD_TASK_NAME_SDK_SECURITY_GET_JWT:
                    SDKSecurityGetJWTURLSessionManager().errorHandler(error: error)
                case API.DOWNLOAD_TASK_NAME_CONTACT_TIMESTAMPS:
                    ContactTimestampsURLSessionManager().errorHandler(error: error)
                case API.DOWNLOAD_TASK_NAME_CONTACT_TIMESTAMP:
                    ContactTimestampURLSessionManager().errorHandler(error: error)
                case API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGES:
                    InAppMessagesURLSessionManager().errorHandler(error: error)
                case API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE:
                    if let inAppMessageURLSessionData = operation.taskData as? InAppMessageURLSessionData {
                        FetchInAppMessageURLSessionManager().errorHandler(inAppMessageURLSessionData: inAppMessageURLSessionData, error: error)
                    }
                case API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE_CONTENT:
                    if let inAppMessageContentURLSessionData = operation.taskData as? InAppMessageContentURLSessionData {
                        InAppMessageContentURLSessionManager().errorHandler(inAppMessageContentURLSessionData: inAppMessageContentURLSessionData, error: error)
                    }
                case API.DOWNLOAD_TASK_NAME_SEND_CUSTOM_EVENTS:
                    if let sendCustomEventsURLSessionData = operation.taskData as? SendCustomEventsURLSessionData {
                        SendCustomEventsURLSessionManager().errorHandler(sendCustomEventsURLSessionData: sendCustomEventsURLSessionData, error: error)
                    }
                case API.DOWNLOAD_TASK_NAME_UPSERT_CONTACTS:
                    if let upsertContactsURLSessionData = operation.taskData as? UpsertContactsURLSessionData {
                        UpsertContactsURLSessionManager().errorHandler(upsertContactsURLSessionData: upsertContactsURLSessionData, error: error)
                    }
                case API.DOWNLOAD_TASK_NAME_SEND_CONTACT_LOGOUT:
                    if let sendContactLogoutURLSessionData = operation.taskData as? SendContactLogoutURLSessionData {
                        SendContactLogoutURLSessionManager().errorHandler(sendContactLogoutURLSessionData: sendContactLogoutURLSessionData, error: error)
                    }
                case API.DOWNLOAD_TASK_NAME_UPSERT_CONTACT_CART:
                    if let upsertContactCartURLSessionData = operation.taskData as? UpsertContactCartURLSessionData {
                        UpsertContactCartURLSessionManager().errorHandler(upsertContactCartURLSessionData: upsertContactCartURLSessionData, error: error)
                    }
                case API.DOWNLOAD_TASK_NAME_SEND_CONTACT_ORDERS:
                    if let sendContactOrdersURLSessionData = operation.taskData as? SendContactOrdersURLSessionData {
                        SendContactOrdersURLSessionManager().errorHandler(sendContactOrdersURLSessionData: sendContactOrdersURLSessionData, error: error)
                    }
                case API.DOWNLOAD_TASK_NAME_INBOX_MESSAGES_READ_UNREAD_MARKS:
                    if let inboxMessagesMarkReadUnreadURLSessionData = operation.taskData as? InboxMessagesMarkReadUnreadURLSessionData {
                        InboxMessagesMarkReadUnreadURLSessionManager().errorHandler(inboxMessagesMarkReadUnreadURLSessionData: inboxMessagesMarkReadUnreadURLSessionData, error: error)
                    }
                case API.DOWNLOAD_TASK_NAME_DELETE_INBOX_MESSAGE:
                    if let inboxMessageDeleteURLSessionData = operation.taskData as? InboxMessageDeleteURLSessionData {
                        InboxMessageDeleteURLSessionManager().errorHandler(inboxMessageDeleteURLSessionData: inboxMessageDeleteURLSessionData, error: error)
                    }
                case API.DOWNLOAD_TASK_NAME_PUSH_NOTIFICATION_CAROUSEL:
                    if let pushNotificationCarouselURLSessionData = operation.taskData as? PushNotificationCarouselURLSessionData {
                        PushNotificationCarouselGetter().errorHandler(pushNotificationCarouselURLSessionData: pushNotificationCarouselURLSessionData, error: error)
                    }
                default: break
                }
            }
        }
        
        self.removeOperation(taskIdentifier: task.taskIdentifier)
    }
    
    // MARK: URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let httpResponse = downloadTask.response as? HTTPURLResponse else { return }
        
        if let operation = self.getOperation(taskIdentifier: downloadTask.taskIdentifier) {
            
            switch InternalCordialAPI().getExpectedCordialURLSessionDataType(taskName: operation.taskName) {
            case .string:
                do {
                    let responseBody = try String(contentsOfFile: location.path)
                    
                    DispatchQueue.main.async {
                        switch operation.taskName {
                        case API.DOWNLOAD_TASK_NAME_SDK_SECURITY_GET_JWT:
                            SDKSecurityGetJWTURLSessionManager().completionHandler(statusCode: httpResponse.statusCode, responseBody: responseBody)
                        case API.DOWNLOAD_TASK_NAME_CONTACT_TIMESTAMPS:
                            ContactTimestampsURLSessionManager().completionHandler(statusCode: httpResponse.statusCode, responseBody: responseBody)
                        case API.DOWNLOAD_TASK_NAME_CONTACT_TIMESTAMP:
                            ContactTimestampURLSessionManager().completionHandler(statusCode: httpResponse.statusCode, responseBody: responseBody)
                        case API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGES:
                            InAppMessagesURLSessionManager().completionHandler(statusCode: httpResponse.statusCode, responseBody: responseBody)
                        case API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE:
                            if let inAppMessageURLSessionData = operation.taskData as? InAppMessageURLSessionData {
                                FetchInAppMessageURLSessionManager().completionHandler(inAppMessageURLSessionData: inAppMessageURLSessionData, statusCode: httpResponse.statusCode, responseBody: responseBody)
                            }
                        case API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE_CONTENT:
                            if let inAppMessageContentURLSessionData = operation.taskData as? InAppMessageContentURLSessionData {
                                InAppMessageContentURLSessionManager().completionHandler(inAppMessageContentURLSessionData: inAppMessageContentURLSessionData, statusCode: httpResponse.statusCode, responseBody: responseBody)
                            }
                        case API.DOWNLOAD_TASK_NAME_SEND_CUSTOM_EVENTS:
                            if let sendCustomEventsURLSessionData = operation.taskData as? SendCustomEventsURLSessionData {
                                SendCustomEventsURLSessionManager().completionHandler(sendCustomEventsURLSessionData: sendCustomEventsURLSessionData, statusCode: httpResponse.statusCode, responseBody: responseBody)
                            }
                        case API.DOWNLOAD_TASK_NAME_UPSERT_CONTACTS:
                            if let upsertContactsURLSessionData = operation.taskData as? UpsertContactsURLSessionData {
                                UpsertContactsURLSessionManager().completionHandler(upsertContactsURLSessionData: upsertContactsURLSessionData, statusCode: httpResponse.statusCode, responseBody: responseBody)
                            }
                        case API.DOWNLOAD_TASK_NAME_SEND_CONTACT_LOGOUT:
                            if let sendContactLogoutURLSessionData = operation.taskData as? SendContactLogoutURLSessionData {
                                SendContactLogoutURLSessionManager().completionHandler(sendContactLogoutURLSessionData: sendContactLogoutURLSessionData, statusCode: httpResponse.statusCode, responseBody: responseBody)
                            }
                        case API.DOWNLOAD_TASK_NAME_UPSERT_CONTACT_CART:
                            if let upsertContactCartURLSessionData = operation.taskData as? UpsertContactCartURLSessionData {
                                UpsertContactCartURLSessionManager().completionHandler(upsertContactCartURLSessionData: upsertContactCartURLSessionData, statusCode: httpResponse.statusCode, responseBody: responseBody)
                            }
                        case API.DOWNLOAD_TASK_NAME_SEND_CONTACT_ORDERS:
                            if let sendContactOrdersURLSessionData = operation.taskData as? SendContactOrdersURLSessionData {
                                SendContactOrdersURLSessionManager().completionHandler(sendContactOrdersURLSessionData: sendContactOrdersURLSessionData, statusCode: httpResponse.statusCode, responseBody: responseBody)
                            }
                        case API.DOWNLOAD_TASK_NAME_INBOX_MESSAGES_READ_UNREAD_MARKS:
                            if let inboxMessagesMarkReadUnreadURLSessionData = operation.taskData as? InboxMessagesMarkReadUnreadURLSessionData {
                                InboxMessagesMarkReadUnreadURLSessionManager().completionHandler(inboxMessagesMarkReadUnreadURLSessionData: inboxMessagesMarkReadUnreadURLSessionData, statusCode: httpResponse.statusCode, responseBody: responseBody)
                            }
                        case API.DOWNLOAD_TASK_NAME_DELETE_INBOX_MESSAGE:
                            if let inboxMessageDeleteURLSessionData = operation.taskData as? InboxMessageDeleteURLSessionData {
                                InboxMessageDeleteURLSessionManager().completionHandler(inboxMessageDeleteURLSessionData: inboxMessageDeleteURLSessionData, statusCode: httpResponse.statusCode, responseBody: responseBody)
                            }
                        default: break
                        }
                    }
                    
                } catch let error {
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("Failed decode response data. Error: [%{public}@]", log: OSLog.cordialInAppMessage, type: .error, error.localizedDescription)
                    }
                }
            case .image:
                if let image = UIImage(named: location.path) {
                    
                    DispatchQueue.main.async {
                        switch operation.taskName {
                        case API.DOWNLOAD_TASK_NAME_PUSH_NOTIFICATION_CAROUSEL:
                            if let pushNotificationCarouselURLSessionData = operation.taskData as? PushNotificationCarouselURLSessionData {
                                PushNotificationCarouselGetter().completionHandler(pushNotificationCarouselURLSessionData: pushNotificationCarouselURLSessionData, statusCode: httpResponse.statusCode, image: image)
                            }
                        default: break
                        }
                    }
                } else {
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("Failed decode response data. Error: [Image data by URL is not a image]", log: OSLog.cordialInAppMessage, type: .error)
                    }
                }
            default: break
            }
        }
        
        self.removeOperation(taskIdentifier: downloadTask.taskIdentifier)
    }

}

//
//  CordialURLSession.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/16/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class CordialURLSession: NSObject, URLSessionDownloadDelegate, URLSessionDelegate {
    
    static var shared = CordialURLSession()
    
    private override init() {}
    
    var backgroundCompletionHandler: (() -> Void)?
    
    private var operations = [Int: CordialURLSessionData]()
    
    private let queue = DispatchQueue(label: "CordialBackgroundURLSessionThreadQueue", attributes: .concurrent)
    
    lazy var backgroundURLSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "CordialBackgroundURLSession")
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
            switch operation.taskName {
            case API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE:
                if let inAppMessageURLSessionData = operation.taskData as? InAppMessageURLSessionData {
                    FetchInAppMessageURLSessionManager().errorHandler(inAppMessageURLSessionData: inAppMessageURLSessionData, error: error)
                }
            case API.DOWNLOAD_TASK_NAME_SDK_SECURITY_GET_JWT:
                SDKSecurityGetJWTURLSessionManager().errorHandler(error: error)
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
            default: break
            }
        }
        
        self.removeOperation(taskIdentifier: task.taskIdentifier)
    }
    
    // MARK: URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let httpResponse = downloadTask.response as? HTTPURLResponse else { return }
        
        if let operation = self.getOperation(taskIdentifier: downloadTask.taskIdentifier) {
            switch operation.taskName {
            case API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE:
                if let inAppMessageURLSessionData = operation.taskData as? InAppMessageURLSessionData {
                    FetchInAppMessageURLSessionManager().completionHandler(inAppMessageURLSessionData: inAppMessageURLSessionData, httpResponse: httpResponse, location: location)
                }
            case API.DOWNLOAD_TASK_NAME_SDK_SECURITY_GET_JWT:
                SDKSecurityGetJWTURLSessionManager().completionHandler(httpResponse: httpResponse, location: location)
            case API.DOWNLOAD_TASK_NAME_SEND_CUSTOM_EVENTS:
                if let sendCustomEventsURLSessionData = operation.taskData as? SendCustomEventsURLSessionData {
                    SendCustomEventsURLSessionManager().completionHandler(sendCustomEventsURLSessionData: sendCustomEventsURLSessionData, httpResponse: httpResponse, location: location)
                }
            case API.DOWNLOAD_TASK_NAME_UPSERT_CONTACTS:
                if let upsertContactsURLSessionData = operation.taskData as? UpsertContactsURLSessionData {
                    UpsertContactsURLSessionManager().completionHandler(upsertContactsURLSessionData: upsertContactsURLSessionData, httpResponse: httpResponse, location: location)
                }
            case API.DOWNLOAD_TASK_NAME_SEND_CONTACT_LOGOUT:
                if let sendContactLogoutURLSessionData = operation.taskData as? SendContactLogoutURLSessionData {
                    SendContactLogoutURLSessionManager().completionHandler(sendContactLogoutURLSessionData: sendContactLogoutURLSessionData, httpResponse: httpResponse, location: location)
                }
            case API.DOWNLOAD_TASK_NAME_UPSERT_CONTACT_CART:
                if let upsertContactCartURLSessionData = operation.taskData as? UpsertContactCartURLSessionData {
                    UpsertContactCartURLSessionManager().completionHandler(upsertContactCartURLSessionData: upsertContactCartURLSessionData, httpResponse: httpResponse, location: location)
                }
            case API.DOWNLOAD_TASK_NAME_SEND_CONTACT_ORDERS:
                if let sendContactOrdersURLSessionData = operation.taskData as? SendContactOrdersURLSessionData {
                    SendContactOrdersURLSessionManager().completionHandler(sendContactOrdersURLSessionData: sendContactOrdersURLSessionData, httpResponse: httpResponse, location: location)
                }
            case API.DOWNLOAD_TASK_NAME_INBOX_MESSAGES_READ_UNREAD_MARKS:
                if let inboxMessagesMarkReadUnreadURLSessionData = operation.taskData as? InboxMessagesMarkReadUnreadURLSessionData {
                    InboxMessagesMarkReadUnreadURLSessionManager().completionHandler(inboxMessagesMarkReadUnreadURLSessionData: inboxMessagesMarkReadUnreadURLSessionData, httpResponse: httpResponse, location: location)
                }
            default: break
            }
        }
        
        self.removeOperation(taskIdentifier: downloadTask.taskIdentifier)
    }

}

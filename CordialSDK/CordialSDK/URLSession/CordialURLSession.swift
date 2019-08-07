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
    
    var operations = [Int: CordialURLSessionData]()
    
    lazy var backgroundURLSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "CordialBackgroundURLSession")
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    // MARK: URLSessionDelegate
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            guard let backgroundCompletionHandler = self.backgroundCompletionHandler else { return }
            backgroundCompletionHandler()
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error, let operation = self.operations[task.taskIdentifier] {
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
            default: break
            }
        }
        
        self.operations.removeValue(forKey: task.taskIdentifier)
    }
    
    // MARK: URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let httpResponse = downloadTask.response as? HTTPURLResponse else { return }
        
        if let operation = self.operations[downloadTask.taskIdentifier] {
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
            default: break
            }
        }
    }

}

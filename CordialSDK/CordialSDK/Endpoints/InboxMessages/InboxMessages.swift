//
//  InboxMessages.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.08.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

class InboxMessages: NSObject, URLSessionDelegate {
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    func getInboxMessagesOrigin(primaryKey: String) {
        if let url = URL(string: CordialApiEndpoints().getInboxMessagesURL(primaryKey: primaryKey)) {
            let request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .GET)
            
            let inboxMessageDownloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
            
            let inboxMessagesURLSessionData = InboxMessagesURLSessionData(primaryKey: primaryKey)
            let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_FETCH_INBOX_MESSAGES, taskData: inboxMessagesURLSessionData)
            CordialURLSession.shared.setOperation(taskIdentifier: inboxMessageDownloadTask.taskIdentifier, data: cordialURLSessionData)
            
            self.requestSender.sendRequest(task: inboxMessageDownloadTask)
        }
    }
    
    // MARK: URLSessionDelegate
    
    lazy var inboxMessagesURLSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func getInboxMessages(primaryKey: String, onComplete: @escaping (_ response: String) -> Void, onError: @escaping (_ error: String) -> Void) {
        if let url = URL(string: CordialApiEndpoints().getInboxMessagesURL(primaryKey: primaryKey)) {
            let request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .GET)
            
            self.inboxMessagesURLSession.dataTask(with: request) { data, response, error in
                if let error = error {
                    onError("Fetching inbox messages with primaryKey: [\(primaryKey)] failed. Error: [\(error.localizedDescription)]")
                    return
                }
                
                if let responseData = data, let httpResponse = response as? HTTPURLResponse {
                    let responseBody = String(decoding: responseData, as: UTF8.self)
                    
                    switch httpResponse.statusCode {
                    case 200:
                        onComplete(responseBody)
                    case 401:
                        SDKSecurity.shared.updateJWTwithCallbacks(onComplete: { response in
                            self.getInboxMessages(primaryKey: primaryKey, onComplete: onComplete, onError: onError)
                        }, onError: { error in
                            onError(error)
                        })
                    default:
                        let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                        let error = "Fetching inbox messages with primaryKey: [\(primaryKey)] failed. Error: [\(message)]"
                        
                        onError(error)
                    }
                } else {
                    let error = "Error: [Inbox messages data is empty with primaryKey: [\(primaryKey)]"
                    onError(error)
                }
            }.resume()
        }
    }
}

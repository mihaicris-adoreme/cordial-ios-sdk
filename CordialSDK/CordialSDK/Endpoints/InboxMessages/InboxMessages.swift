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
    
    lazy var inboxMessagesURLSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func getInboxMessages(primaryKey: String) {
        if let url = URL(string: CordialApiEndpoints().getInboxMessagesURL(primaryKey: primaryKey)) {
            let request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .GET)
            
            self.inboxMessagesURLSession.dataTask(with: request) { data, response, error in
                if let error = error {
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("Fetching inbox messages with primaryKey: [%{public}@] failed. Error: [%{public}@]", log: OSLog.cordialInboxMessages, type: .error, primaryKey, error.localizedDescription)
                    }
                    
                    return
                }
                
                if let responseData = data, let httpResponse = response as? HTTPURLResponse {
                    let responseBody = String(decoding: responseData, as: UTF8.self)
                    
                    switch httpResponse.statusCode {
                    case 200:
                        print(responseBody)
                    case 401:
                        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                            let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                            
                            os_log("Fetching inbox messages with primaryKey: [%{public}@] failed. Error: [%{public}@]", log: OSLog.cordialInboxMessages, type: .error, primaryKey, message)
                        }

                        SDKSecurity.shared.updateJWT()
                    default:
                        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                            let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                            
                            os_log("Fetching inbox messages with primaryKey: [%{public}@] failed. Error: [%{public}@]", log: OSLog.cordialInboxMessages, type: .error, primaryKey, message)
                        }
                    }
                } else {
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("Error: [Inbox messages data is empty with primaryKey: [%{public}@]]", log: OSLog.cordialInboxMessages, type: .error, primaryKey)
                    }
                }
            }.resume()
        }
    }
}

//
//  InAppMessages.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 09.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

class InAppMessages {
    
    static let shared = InAppMessages()
    
    private init() {}
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    var isCurrentlyUpdatingInAppMessages = false
    
    func updateIfNeeded() {
        if !self.isCurrentlyUpdatingInAppMessages {
            self.fetchInAppMessages()
        }
    }
    
    private func fetchInAppMessages() {
        self.isCurrentlyUpdatingInAppMessages = true
        
        if InternalCordialAPI().isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                if InternalCordialAPI().getCurrentJWT() != nil {
                    
                    LoggerManager.shared.info(message: "Fetching IAMs has been started", category: "CordialSDKInAppMessages")
                    
                    if let contactKey = InternalCordialAPI().getContactKey(),
                       let url = URL(string: CordialApiEndpoints().getInAppMessagesURL(contactKey: contactKey)) {
                        
                        let request = CordialRequestFactory().getCordialURLRequest(url: url, httpMethod: .GET)

                        let downloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)

                        let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGES, taskData: nil)
                        CordialURLSession.shared.setOperation(taskIdentifier: downloadTask.taskIdentifier, data: cordialURLSessionData)

                        self.requestSender.sendRequest(task: downloadTask)
                    } else {
                        let message = "Fetching IAMs failed. Error: [Unexpected error]"
                        let responseError = ResponseError(message: message, statusCode: nil, responseBody: nil, systemError: nil)
                        self.errorHandler(error: responseError)
                    }
                } else {
                    let message = "Fetching IAMs failed. Error: [JWT is absent]"
                    let responseError = ResponseError(message: message, statusCode: nil, responseBody: nil, systemError: nil)
                    self.errorHandler(error: responseError)
                    
                    SDKSecurity.shared.updateJWT()
                }
            } else {
                let message = "Fetching IAMs failed. Error: [No Internet connection]"
                let responseError = ResponseError(message: message, statusCode: nil, responseBody: nil, systemError: nil)
                self.errorHandler(error: responseError)
            }
        } else {
            let message = "Fetching IAMs failed. Error: [User no login]"
            let responseError = ResponseError(message: message, statusCode: nil, responseBody: nil, systemError: nil)
            self.errorHandler(error: responseError)
        }
    }
    
    func completionHandler(messages: [Dictionary<String, AnyObject>]) {
        self.isCurrentlyUpdatingInAppMessages = false
        
        if messages.isEmpty {
            InAppMessage().initTheLatestSentAtInAppMessageDate()
            
            LoggerManager.shared.info(message: "Fetching IAMs has been finished: [There are no IAMs available]", category: "CordialSDKInAppMessages")
        } else {
            InAppMessagesGetter().setInAppMessagesParamsToCoreData(messages: messages)
        }
    }
    
    func errorHandler(error: ResponseError) {
        self.isCurrentlyUpdatingInAppMessages = false
        
        LoggerManager.shared.error(message: "Fetching IAMs failed. Error: [\(error.message)]", category: "CordialSDKInAppMessages")
    }
}

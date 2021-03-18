//
//  InAppMessages.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 09.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import os.log

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
                    
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                        os_log("Fetching IAMs has been start.", log: OSLog.cordialInAppMessages, type: .info)
                    }
                    
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
        
        if !messages.isEmpty {
            InAppMessagesGetter().setInAppMessagesParamsToCoreData(messages: messages)
        }
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("IAMs has been successfully fetch.", log: OSLog.cordialInAppMessages, type: .info)
        }
    }
    
    func errorHandler(error: ResponseError) {
        self.isCurrentlyUpdatingInAppMessages = false
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("%{public}@", log: OSLog.cordialInAppMessages, type: .error, error.message)
        }
    }
}

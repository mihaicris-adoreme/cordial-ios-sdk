//
//  ContactTimestampURL.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 12.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

class ContactTimestampURL {
    
    static let shared = ContactTimestampURL()
    
    private init() {}
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    var isCurrentlyUpdatingContactTimestampURL = false
    
    func updateIfNeeded(_ url: URL) {
        if !self.isCurrentlyUpdatingContactTimestampURL {
            self.fetchContactTimestampURL(url: url)
        }
    }
    
    private func fetchContactTimestampURL(url: URL) {
        self.isCurrentlyUpdatingContactTimestampURL = true
        
        if InternalCordialAPI().isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                // This is S3 - No need check JWT
                
                let request = CordialRequestFactory().getBaseURLRequest(url: url, httpMethod: .GET)

                let downloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)

                let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_CONTACT_TIMESTAMP, taskData: nil)
                CordialURLSession.shared.setOperation(taskIdentifier: downloadTask.taskIdentifier, data: cordialURLSessionData)

                self.requestSender.sendRequest(task: downloadTask)
                
            } else {
                let message = "Fetching timestamp URL failed. Error: [No Internet connection]"
                let responseError = ResponseError(message: message, statusCode: nil, responseBody: nil, systemError: nil)
                self.errorHandler(error: responseError)
            }
        } else {
            let message = "Fetching timestamp URL failed. Error: [User no login]"
            let responseError = ResponseError(message: message, statusCode: nil, responseBody: nil, systemError: nil)
            self.errorHandler(error: responseError)
        }
    }
    
    func completionHandler(contactTimestampData: ContactTimestampData) {
        self.isCurrentlyUpdatingContactTimestampURL = false
        
        let cordialDateFormatter = CordialDateFormatter()
        
        if let currentSentAtTimestampIAM = InternalCordialAPI().getTheLatestSentAtInAppMessageDate() {
            
            if let currentSentAtIAM = cordialDateFormatter.getDateFromTimestamp(timestamp: currentSentAtTimestampIAM),
               let contactSentAtIAM = contactTimestampData.inApp,
               contactSentAtIAM.timeIntervalSince1970 > currentSentAtIAM.timeIntervalSince1970 {
               
                InAppMessages.shared.updateIfNeeded()
            }

        } else {
            InAppMessages.shared.updateIfNeeded()
        }
    }
    
    func errorHandler(error: ResponseError) {
        self.isCurrentlyUpdatingContactTimestampURL = false
        
        LoggerManager.shared.error(message: "\(error.message)", category: "CordialSDKContactTimestamps")
    }
}

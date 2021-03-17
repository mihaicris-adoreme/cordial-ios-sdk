//
//  ContactTimestampURL.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 12.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import os.log

class ContactTimestampURL {
    
    static let shared = ContactTimestampURL()
    
    private init() {}
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    var isCurrentlyUpdatingContactTimestampURL = false
    
    func updateIfNeeded(_ url: URL?) {
        if !self.isCurrentlyUpdatingContactTimestampURL {
            
            if let url = url {
                self.fetchContactTimestampURL(url: url)
            } else if let contactTimestamp = CoreDataManager.shared.contactTimestampsURL.getContactTimestampFromCoreData(),
                      API.isValidExpirationDate(date: contactTimestamp.expireDate) {
                    
                self.fetchContactTimestampURL(url: contactTimestamp.url)
                
            }
            
        }
    }
    
    private func fetchContactTimestampURL(url: URL) {
        self.isCurrentlyUpdatingContactTimestampURL = true
        
        let request = CordialRequestFactory().getBaseURLRequest(url: url, httpMethod: .GET)

        let downloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)

        let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_CONTACT_TIMESTAMP, taskData: nil)
        CordialURLSession.shared.setOperation(taskIdentifier: downloadTask.taskIdentifier, data: cordialURLSessionData)

        self.requestSender.sendRequest(task: downloadTask)
    }
    
    func completionHandler(contactTimestampData: ContactTimestampData) {
        self.isCurrentlyUpdatingContactTimestampURL = false
        
        let cordialDateFormatter = CordialDateFormatter()
        
        if let currentSentAtTimestampIAM = InternalCordialAPI().getTheLatestSentAtInAppMessageDate(),
           let currentSentAtIAM = cordialDateFormatter.getDateFromTimestamp(timestamp: currentSentAtTimestampIAM),
           let contactSentAtIAM = contactTimestampData.inApp,
           contactSentAtIAM.timeIntervalSince1970 > currentSentAtIAM.timeIntervalSince1970 {
            
            InAppMessages.shared.updateIfNeeded()
        }
    }
    
    func errorHandler(error: ResponseError) {
        self.isCurrentlyUpdatingContactTimestampURL = false
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("%{public}@", log: OSLog.cordialContactTimestamps, type: .error, error.message)
        }
    }
}

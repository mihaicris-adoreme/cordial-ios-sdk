//
//  ContactTimestamps.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 26.02.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import os.log

class ContactTimestamps {
    
    static let shared = ContactTimestamps()
    
    private init() {}
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    var isCurrentlyUpdatingContactTimestamps = false
    
    func updateIfNeeded() {
        if !self.isCurrentlyUpdatingContactTimestamps {
            
            if let contactTimestamp = ContactTimestampsURLCoreData().getContactTimestampFromCoreData() {
                
                if !API.isValidExpirationDate(date: contactTimestamp.expireDate) {
                    self.updateContactTimestamps()
                }
                
            } else {
                self.updateContactTimestamps()
            }
        }
    }
    
    private func updateContactTimestamps() {
        self.isCurrentlyUpdatingContactTimestamps = true
        
        if let contactKey = InternalCordialAPI().getContactKey(),
           let url = URL(string: CordialApiEndpoints().getContactTimestampsURL(contactKey: contactKey)) {
            
            let request = CordialRequestFactory().getCordialURLRequest(url: url, httpMethod: .GET)

            let downloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)

            let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_CONTACT_TIMESTAMPS, taskData: nil)
            CordialURLSession.shared.setOperation(taskIdentifier: downloadTask.taskIdentifier, data: cordialURLSessionData)

            self.requestSender.sendRequest(task: downloadTask)
        } else {
            let message = "Fetching contact timestamp failed. Error: [Unexpected error]"
            let responseError = ResponseError(message: message, statusCode: nil, responseBody: nil, systemError: nil)
            self.errorHandler(error: responseError)
        }
    }
       
    func completionHandler(contactTimestamp: ContactTimestamp) {
        self.isCurrentlyUpdatingContactTimestamps = false
        
        ContactTimestampsURLCoreData().putContactTimestampToCoreData(contactTimestamp: contactTimestamp)
        
        ContactTimestampURL.shared.updateIfNeeded(contactTimestamp.url)
    }
    
    func errorHandler(error: ResponseError) {
        self.isCurrentlyUpdatingContactTimestamps = false
        
        if !self.isEmptyContactTimestamps(error: error) {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("%{public}@", log: OSLog.cordialContactTimestamps, type: .error, error.message)
            }
        }
    }
    
    private func isEmptyContactTimestamps(error: ResponseError) -> Bool {
        if error.statusCode == 404, let responseBody = error.responseBody {
            if let responseBodyData = responseBody.data(using: .utf8),
               let responseBodyJSONSerialization = try? JSONSerialization.jsonObject(with: responseBodyData, options: []),
               let responseBodyJSON = responseBodyJSONSerialization as? [String: AnyObject],
               let error = responseBodyJSON["error"] as? [String: AnyObject],
               let message = error["message"] as? String,
               message == "Timestamps file has not been found" {
                    
                return true
            }
        }
        
        return false
    }
}

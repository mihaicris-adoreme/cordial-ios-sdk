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
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    func update() {
        if let contactKey = InternalCordialAPI().getContactKey(),
           let url = URL(string: CordialApiEndpoints().getContactTimestampsURL(contactKey: contactKey)) {
            
            let request = CordialRequestFactory().getCordialURLRequest(url: url, httpMethod: .GET)

            let downloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)

            let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_CONTACT_TIMESTAMPS, taskData: nil)
            CordialURLSession.shared.setOperation(taskIdentifier: downloadTask.taskIdentifier, data: cordialURLSessionData)

            self.requestSender.sendRequest(task: downloadTask)
        } else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Fetching contact timestamp failed. Error: [Unexpected error]", log: OSLog.cordialContactTimestamps, type: .info)
            }
        }
    }
       
    func completionHandler(url: URL) {
        // TODO
    }
    
    func errorHandler(error: ResponseError) {
        if !self.isEmptyContactTimestamps(error: error) {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Fetching contact timestamp failed. Error: [%{public}@]", log: OSLog.cordialContactTimestamps, type: .error, error.message)
            }
        }
    }
    
    private func isEmptyContactTimestamps(error: ResponseError) -> Bool {
        if error.statusCode == 404, let responseBody = error.responseBody {
            if let responseBodyData = responseBody.data(using: .utf8),
               let responseBodyJSON = try? JSONSerialization.jsonObject(with: responseBodyData, options: []) as? [String: AnyObject],
               let error = responseBodyJSON["error"] as? [String: AnyObject],
               let message = error["message"] as? String,
               message == "Timestamps file has not been found" {
                    
                return true
            }
        }
        
        return false
    }
}

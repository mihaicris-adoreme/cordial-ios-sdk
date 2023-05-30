//
//  ContactTimestamps.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 26.02.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

class ContactTimestamps {
    
    static let shared = ContactTimestamps()
    
    private init() {}
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    var isCurrentlyUpdatingContactTimestamps = false
    
    func updateIfNeeded() {
        if !self.isCurrentlyUpdatingContactTimestamps {
            
            if let contactTimestamp = CoreDataManager.shared.contactTimestampsURL.getContactTimestampFromCoreData() {
                
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
        
        if InternalCordialAPI().isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                if InternalCordialAPI().getCurrentJWT() != nil {
                    
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
                    
                } else {
                    let message = "Fetching contact timestamp failed. Error: [JWT is absent]"
                    let responseError = ResponseError(message: message, statusCode: nil, responseBody: nil, systemError: nil)
                    self.errorHandler(error: responseError)
                    
                    SDKSecurity.shared.updateJWT()
                }
            } else {
                let message = "Fetching contact timestamp failed. Error: [No Internet connection]"
                let responseError = ResponseError(message: message, statusCode: nil, responseBody: nil, systemError: nil)
                self.errorHandler(error: responseError)
            }
        } else {
            self.isCurrentlyUpdatingContactTimestamps = false
        }
    }
       
    func completionHandler(contactTimestamp: ContactTimestamp) {
        self.isCurrentlyUpdatingContactTimestamps = false
        
        CoreDataManager.shared.contactTimestampsURL.putContactTimestampToCoreData(contactTimestamp: contactTimestamp)
        
        ContactTimestampURL.shared.updateIfNeeded(contactTimestamp.url)
    }
    
    func errorHandler(error: ResponseError) {
        self.isCurrentlyUpdatingContactTimestamps = false
        
        if !self.isEmptyContactTimestamps(error: error) {
            LoggerManager.shared.error(message: "\(error.message)", category: "CordialSDKContactTimestamps")
        }
    }
    
    private func isEmptyContactTimestamps(error: ResponseError) -> Bool {
        
        switch error.statusCode {
        case 400:
            LoggerManager.shared.info(message: "No timestamps URL yet", category: "CordialSDKContactTimestamps")
            
            return true
        case 404:
            if let responseBody = error.responseBody {
                if let responseBodyData = responseBody.data(using: .utf8),
                   let responseBodyJSONSerialization = try? JSONSerialization.jsonObject(with: responseBodyData, options: []),
                   let responseBodyJSON = responseBodyJSONSerialization as? [String: AnyObject],
                   let message = responseBodyJSON["message"] as? [String: AnyObject],
                   let errorCode = message["errorCode"] as? String,
                   errorCode == "no_timestamps_file" {
                        
                    return true
                }
            }
        default: break
        }
        
        return false
    }
}

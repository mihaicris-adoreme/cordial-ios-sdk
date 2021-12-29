//
//  ContactTimestampURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 12.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

class ContactTimestampURLSessionManager {
    
    let contactTimestampURL = ContactTimestampURL.shared
    
    func completionHandler(statusCode: Int, responseBody: String) {
        switch statusCode {
        case 200:
            do {
                if let responseBodyData = responseBody.data(using: .utf8),
                   let responseBodyJSON = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as? [String: String] {
                    
                    var inApp: Date?
                    var inbox: Date?
                    
                    let cordialDateFormatter = CordialDateFormatter()
                    
                    if let inAppTimestamp = responseBodyJSON["inApp"] {
                        inApp = cordialDateFormatter.getDateFromTimestamp(timestamp: inAppTimestamp)
                    }
                    if let inboxTimestamp = responseBodyJSON["inbox"] {
                        inbox = cordialDateFormatter.getDateFromTimestamp(timestamp: inboxTimestamp)
                    }
                    
                    let contactTimestampData = ContactTimestampData(inApp: inApp, inbox: inbox)
                    self.contactTimestampURL.completionHandler(contactTimestampData: contactTimestampData)
                } else {
                    let message = "Failed decode response data."
                    let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
                    self.contactTimestampURL.errorHandler(error: responseError)
                }
            } catch let error {
                let message = "Failed decode response data. Error: [\(error.localizedDescription)]"
                let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
                self.contactTimestampURL.errorHandler(error: responseError)
            }
        case 400:
            self.contactTimestampURL.isCurrentlyUpdatingContactTimestampURL = false
            
            InternalCordialAPI().removeContactTimestampFromCoreDataAndTheLatestSentAtInAppMessageDate()
            
            ContactTimestamps.shared.updateIfNeeded()
        default:
            let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            self.contactTimestampURL.errorHandler(error: responseError)
        }
    }
    
    func errorHandler(error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        self.contactTimestampURL.errorHandler(error: responseError)
    }
    
}


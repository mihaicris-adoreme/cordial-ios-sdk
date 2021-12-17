//
//  ContactTimestampsURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 26.02.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

class ContactTimestampsURLSessionManager {
    
    let contactTimestamps = ContactTimestamps.shared
    
    func completionHandler(statusCode: Int, responseBody: String) {
        switch statusCode {
        case 200:
            do {
                if let responseBodyData = responseBody.data(using: .utf8),
                   let responseBodyJSON = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as? [String: AnyObject],
                   let urlString = responseBodyJSON["url"] as? String,
                   let url = URL(string: urlString),
                   let expireTimestamp = responseBodyJSON["urlExpireAt"] as? String,
                   let expireDate = CordialDateFormatter().getDateFromTimestamp(timestamp: expireTimestamp) {
                    
                    let contactTimestamp = ContactTimestamp(url: url, expireDate: expireDate)
                    self.contactTimestamps.completionHandler(contactTimestamp: contactTimestamp)
                } else {
                    let message = "Failed decode response data."
                    let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
                    self.contactTimestamps.errorHandler(error: responseError)
                }
            } catch let error {
                let message = "Failed decode response data. Error: [\(error.localizedDescription)]"
                let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
                self.contactTimestamps.errorHandler(error: responseError)
            }
        case 401:
            self.contactTimestamps.isCurrentlyUpdatingContactTimestamps = false
            
            SDKSecurity.shared.updateJWT()
        default:
            let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            self.contactTimestamps.errorHandler(error: responseError)
        }
    }
    
    func errorHandler(error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        self.contactTimestamps.errorHandler(error: responseError)
    }
    
}

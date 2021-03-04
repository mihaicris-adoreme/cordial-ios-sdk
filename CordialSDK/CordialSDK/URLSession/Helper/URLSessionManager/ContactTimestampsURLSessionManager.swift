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
    
    func completionHandler(httpResponse: HTTPURLResponse, location: URL) {
        do {
            let responseBody = try String(contentsOfFile: location.path)
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    if let responseBodyData = responseBody.data(using: .utf8), let responseBodyJSON = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as? [String: AnyObject] {
                        if let urlString = responseBodyJSON["url"] as? String,
                           let url = URL(string: urlString) {
                            self.contactTimestamps.completionHandler(url: url)
                        } else {
                            let message = "Contact timestamps URL is absent"
                            let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                            self.contactTimestamps.errorHandler(error: responseError)
                        }
                    } else {
                        let message = "Failed decode response data."
                        let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                        self.contactTimestamps.errorHandler(error: responseError)
                    }
                } catch let error {
                    let message = "Failed decode response data. Error: [\(error.localizedDescription)]"
                    let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                    self.contactTimestamps.errorHandler(error: responseError)
                }
            case 401:
                self.contactTimestamps.isCurrentlyUpdatingContactTimestamps = false
                
                SDKSecurity.shared.updateJWT()
            default:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                self.contactTimestamps.errorHandler(error: responseError)
            }
        } catch let error {
            let message = "Failed decode response data. Error: [\(error.localizedDescription)]"
            let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: nil, systemError: nil)
            self.contactTimestamps.errorHandler(error: responseError)
        }
    }
    
    func errorHandler(error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        self.contactTimestamps.errorHandler(error: responseError)
    }
    
}

//
//  UpsertContactsURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class UpsertContactsURLSessionManager {
    
    let contactsSender = ContactsSender()
    
    func completionHandler(upsertContactsURLSessionData: UpsertContactsURLSessionData, httpResponse: HTTPURLResponse, location: URL) {
        do {
            let responseBody = try String(contentsOfFile: location.path)
            
            switch httpResponse.statusCode {
            case 200:
                self.contactsSender.completionHandler(upsertContactRequests: upsertContactsURLSessionData.upsertContactRequests)
            case 401:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                self.contactsSender.systemErrorHandler(upsertContactRequests: upsertContactsURLSessionData.upsertContactRequests, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            default:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                
                self.contactsSender.logicErrorHandler(error: responseError)
            }
        } catch {
            os_log("Failed decode response data", log: OSLog.cordialUpsertContacts, type: .error)
        }
    }
    
    func errorHandler(upsertContactsURLSessionData: UpsertContactsURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        self.contactsSender.systemErrorHandler(upsertContactRequests: upsertContactsURLSessionData.upsertContactRequests, error: responseError)
    }
    
}

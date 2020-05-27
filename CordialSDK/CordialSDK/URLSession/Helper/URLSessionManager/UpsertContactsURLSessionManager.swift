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
    
    let contactsSender = ContactsSender.shared
    
    func completionHandler(upsertContactsURLSessionData: UpsertContactsURLSessionData, httpResponse: HTTPURLResponse, location: URL) {
        let upsertContactRequests = upsertContactsURLSessionData.upsertContactRequests
        
        do {
            let responseBody = try String(contentsOfFile: location.path)
            
            switch httpResponse.statusCode {
            case 200:
                self.contactsSender.completionHandler(upsertContactRequests: upsertContactRequests)
            case 401:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                self.contactsSender.systemErrorHandler(upsertContactRequests: upsertContactRequests, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            default:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                
                self.contactsSender.logicErrorHandler(upsertContactRequests: upsertContactRequests, error: responseError)
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                upsertContactRequests.forEach({ upsertContactRequest in
                    os_log("Failed decode upsert contacts response data. Request ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialUpsertContacts, type: .error, upsertContactRequest.requestID, error.localizedDescription)
                })
            }
        }
    }
    
    func errorHandler(upsertContactsURLSessionData: UpsertContactsURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        self.contactsSender.systemErrorHandler(upsertContactRequests: upsertContactsURLSessionData.upsertContactRequests, error: responseError)
    }
    
}

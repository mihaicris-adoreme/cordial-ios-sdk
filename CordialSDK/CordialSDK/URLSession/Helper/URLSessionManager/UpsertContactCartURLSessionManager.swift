//
//  UpsertContactCartURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class UpsertContactCartURLSessionManager {
    
    let contactCartSender = ContactCartSender()
    
    func completionHandler(upsertContactCartURLSessionData: UpsertContactCartURLSessionData, httpResponse: HTTPURLResponse, location: URL) {
        let upsertContactCartRequest = upsertContactCartURLSessionData.upsertContactCartRequest
        
        do {
            let responseBody = try String(contentsOfFile: location.path)
            
            switch httpResponse.statusCode {
            case 200:
                contactCartSender.completionHandler(upsertContactCartRequest: upsertContactCartRequest)
            case 401:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                contactCartSender.systemErrorHandler(upsertContactCartRequest: upsertContactCartRequest, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            default:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                contactCartSender.logicErrorHandler(upsertContactCartRequest: upsertContactCartRequest, error: responseError)
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Failed decode upsert contact cart response data. Request ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialUpsertContactCart, type: .error, upsertContactCartRequest.requestID, error.localizedDescription)
            }
        }
    }
    
    func errorHandler(upsertContactCartURLSessionData: UpsertContactCartURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        contactCartSender.systemErrorHandler(upsertContactCartRequest: upsertContactCartURLSessionData.upsertContactCartRequest, error: responseError)
    }
}

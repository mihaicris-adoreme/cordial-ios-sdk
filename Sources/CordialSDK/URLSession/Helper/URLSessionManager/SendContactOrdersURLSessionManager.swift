//
//  SendContactOrdersURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class SendContactOrdersURLSessionManager {
    
    let contactOrdersSender = ContactOrdersSender()
    
    func completionHandler(sendContactOrdersURLSessionData: SendContactOrdersURLSessionData, statusCode: Int, location: URL) {
        let sendContactOrderRequests = sendContactOrdersURLSessionData.sendContactOrderRequests
        
        do {
            let responseBody = try String(contentsOfFile: location.path)
            
            switch statusCode {
            case 200:
                contactOrdersSender.completionHandler(sendContactOrderRequests: sendContactOrderRequests)
            case 401:
                let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
                let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
                contactOrdersSender.systemErrorHandler(sendContactOrderRequests: sendContactOrderRequests, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            default:
                let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
                let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
                contactOrdersSender.logicErrorHandler(sendContactOrderRequests: sendContactOrderRequests, error: responseError)
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                sendContactOrderRequests.forEach({ sendContactOrderRequest in
                    os_log("Failed decode contact orders response data. Order ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialSendContactOrders, type: .error, sendContactOrderRequest.order.orderID, error.localizedDescription)
                })
            }
        }
    }
    
    func errorHandler(sendContactOrdersURLSessionData: SendContactOrdersURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        contactOrdersSender.systemErrorHandler(sendContactOrderRequests: sendContactOrdersURLSessionData.sendContactOrderRequests, error: responseError)
    }
}

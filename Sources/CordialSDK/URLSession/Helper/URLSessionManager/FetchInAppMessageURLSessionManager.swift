//
//  FetchInAppMessageURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/6/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class FetchInAppMessageURLSessionManager {
    
    let inAppMessageGetter = InAppMessageGetter()
    
    func completionHandler(inAppMessageURLSessionData: InAppMessageURLSessionData, statusCode: Int, responseBody: String) {
        let mcID = inAppMessageURLSessionData.mcID
        
        switch statusCode {
        case 200:
            do {
                if let responseBodyData = responseBody.data(using: .utf8),
                   let responseBodyJSON = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as? [String: AnyObject],
                   let html = responseBodyJSON["content"] as? String {
                   
                    if let inAppMessageParams = CoreDataManager.shared.inAppMessagesParam.fetchInAppMessageParams(mcID: mcID) {
                        
                        let inAppMessageData = InAppMessage().getInAppMessageData(inAppMessageParams: inAppMessageParams, html: html)
                        
                        self.inAppMessageGetter.completionHandler(inAppMessageData: inAppMessageData)
                    } else {
                        let message = "Failed to parse IAM response."
                        let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
                        self.inAppMessageGetter.logicErrorHandler(mcID: mcID, error: responseError)
                    }
                } else {
                    let message = "Failed to parse IAM response."
                    let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
                    self.inAppMessageGetter.logicErrorHandler(mcID: mcID, error: responseError)
                }
            } catch let error {
                LoggerManager.shared.error(message: "Failed decode response data. mcID: [\(mcID)] Error: [\(error.localizedDescription)]", category: "CordialSDKInAppMessage")
            }
        case 401:
            let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            self.inAppMessageGetter.systemErrorHandler(mcID: mcID, error: responseError)
            
            SDKSecurity.shared.updateJWT()
        default:
            let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            self.inAppMessageGetter.logicErrorHandler(mcID: mcID, error: responseError)
        }
    }
    
    func errorHandler(inAppMessageURLSessionData: InAppMessageURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        self.inAppMessageGetter.systemErrorHandler(mcID: inAppMessageURLSessionData.mcID, error: responseError)
    }

}

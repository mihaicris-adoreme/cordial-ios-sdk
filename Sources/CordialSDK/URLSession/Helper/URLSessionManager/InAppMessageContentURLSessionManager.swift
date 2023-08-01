//
//  InAppMessageContentURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 17.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

class InAppMessageContentURLSessionManager {
    
    let inAppMessageContentGetter = InAppMessageContentGetter()
        
    func completionHandler(inAppMessageContentURLSessionData: InAppMessageContentURLSessionData, statusCode: Int, responseBody: String) {
        let mcID = inAppMessageContentURLSessionData.mcID
        
        switch statusCode {
        case 200:
            do {
                if let responseBodyData = responseBody.data(using: .utf8),
                   let responseBodyJSON = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as? [String: AnyObject],
                   let html = responseBodyJSON["content"] as? String {
                   
                    if let inAppMessageParams = CoreDataManager.shared.inAppMessagesParam.fetchInAppMessageParams(mcID: mcID) {
                        
                        let inAppMessageData = InAppMessage().getInAppMessageData(inAppMessageParams: inAppMessageParams, html: html)
                        
                        self.inAppMessageContentGetter.completionHandler(inAppMessageData: inAppMessageData)
                    } else {
                        let message = "Failed to parse IAM response."
                        let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
                        self.inAppMessageContentGetter.errorHandler(mcID: mcID, error: responseError)
                    }
                } else {
                    let message = "Failed to parse IAM response."
                    let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
                    self.inAppMessageContentGetter.errorHandler(mcID: mcID, error: responseError)
                }
            } catch let error {
                let message = "Failed decode response data. mcID: [\(mcID)] Error: [\(error.localizedDescription)]"
                let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
                self.inAppMessageContentGetter.errorHandler(mcID: mcID, error: responseError)
            }
        case 400:
            let message = "Fetching IAM content failed. Error: [URL has been expired]. mcID: [\(mcID)]"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            self.inAppMessageContentGetter.errorHandler(mcID: mcID, error: responseError)
        default:
            let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            self.inAppMessageContentGetter.errorHandler(mcID: mcID, error: responseError)
        }
    }
    
    func errorHandler(inAppMessageContentURLSessionData: InAppMessageContentURLSessionData, error: Error) {
        let mcID = inAppMessageContentURLSessionData.mcID
        
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        self.inAppMessageContentGetter.errorHandler(mcID: mcID, error: responseError)
    }
    
}

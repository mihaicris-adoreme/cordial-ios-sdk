//
//  FetchInAppMessageURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/6/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class FetchInAppMessageURLSessionManager {
    
    let inAppMessageGetter = InAppMessageGetter()
    
    func completionHandler(inAppMessageURLSessionData: InAppMessageURLSessionData, httpResponse: HTTPURLResponse, location: URL) {
        let mcID = inAppMessageURLSessionData.mcID
        
        do {
            let responseBody = try String(contentsOfFile: location.path)
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    if let responseBodyData = responseBody.data(using: .utf8),
                       let responseBodyJSON = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as? [String: AnyObject],
                       let html = responseBodyJSON["content"] as? String {
                       
                        DispatchQueue.main.async {
                            if let inAppMessageParams = CoreDataManager.shared.inAppMessagesParam.fetchInAppMessageParamsByMcID(mcID: mcID) {
                                
                                let inAppMessageData = InAppMessage().getInAppMessageData(inAppMessageParams: inAppMessageParams, html: html)
                                
                                self.inAppMessageGetter.completionHandler(inAppMessageData: inAppMessageData)
                            } else {
                                let message = "Failed to parse IAM response."
                                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                                self.inAppMessageGetter.logicErrorHandler(mcID: mcID, error: responseError)
                            }
                        }
                    } else {
                        let message = "Failed to parse IAM response."
                        let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                        self.inAppMessageGetter.logicErrorHandler(mcID: mcID, error: responseError)
                    }
                } catch let error {
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("Failed decode response data. mcID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialInAppMessage, type: .error, mcID, error.localizedDescription)
                    }
                }
            case 401:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                self.inAppMessageGetter.systemErrorHandler(mcID: mcID, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            default:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                self.inAppMessageGetter.logicErrorHandler(mcID: mcID, error: responseError)
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Failed decode response data. mcID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialInAppMessage, type: .error, mcID, error.localizedDescription)
            }
        }
    }
    
    func errorHandler(inAppMessageURLSessionData: InAppMessageURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        self.inAppMessageGetter.systemErrorHandler(mcID: inAppMessageURLSessionData.mcID, error: responseError)
    }

}

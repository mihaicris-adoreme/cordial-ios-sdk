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
                       let html = responseBodyJSON["content"] as? String,
                       let inAppMessageParams = CoreDataManager.shared.inAppMessagesParam.fetchInAppMessageParamsByMcID(mcID: mcID) {
                        
                        let type = inAppMessageParams.type
                        let displayType = inAppMessageParams.displayType
                        let expirationTime = inAppMessageParams.expirationTime
                        
                        var inAppMessageData: InAppMessageData?
                        
                        switch type {
                        case InAppMessageType.modal:
                            let top = Int(inAppMessageParams.top)
                            let right = Int(inAppMessageParams.right)
                            let bottom = Int(inAppMessageParams.bottom)
                            let left = Int(inAppMessageParams.left)
                            
                            inAppMessageData = InAppMessageData(mcID: mcID, html: html, type: type, displayType: displayType, top: top, right: right, bottom: bottom, left: left, expirationTime: expirationTime)
                        case InAppMessageType.fullscreen:
                            let top = 0
                            let right = 0
                            let bottom = 0
                            let left = 0
                            
                            inAppMessageData = InAppMessageData(mcID: mcID, html: html, type: type, displayType: displayType, top: top, right: right, bottom: bottom, left: left, expirationTime: expirationTime)
                        case InAppMessageType.banner_up:
                            let height = inAppMessageParams.height
                            
                            let top = 5
                            let right = 5
                            let bottom = Int(100 - Double(height) / 100.0 * 100)
                            let left = 5
                            
                            inAppMessageData = InAppMessageData(mcID: mcID, html: html, type: type, displayType: displayType, top: top, right: right, bottom: bottom, left: left, expirationTime: expirationTime)
                        case InAppMessageType.banner_bottom:
                            let height = inAppMessageParams.height
                            
                            let top = Int(100 - Double(height) / 100.0 * 100)
                            let right = 5
                            let bottom = 5
                            let left = 5
                            
                            inAppMessageData = InAppMessageData(mcID: mcID, html: html, type: type, displayType: displayType, top: top, right: right, bottom: bottom, left: left, expirationTime: expirationTime)
                        }
                        
                        if let inAppMessageData = inAppMessageData {
                            self.inAppMessageGetter.completionHandler(inAppMessageData: inAppMessageData)
                        }
                    } else {
                        let message = "Failed to parse IAM response."
                        let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                        self.inAppMessageGetter.logicErrorHandler(mcID: mcID, error: responseError)
                        
                        CoreDataManager.shared.inAppMessagesParam.deleteInAppMessageParamsByMcID(mcID: mcID)
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
                
                CoreDataManager.shared.inAppMessagesParam.deleteInAppMessageParamsByMcID(mcID: mcID)
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

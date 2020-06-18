//
//  InAppMessageGetter.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/3/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class InAppMessageGetter {
    
    let pushNotificationParser = CordialPushNotificationParser()
    
    func startFetchInAppMessage(userInfo: [AnyHashable : Any]) {
        if let mcID = self.pushNotificationParser.getMcID(userInfo: userInfo) {
            let typeString = self.pushNotificationParser.getTypeIAM(userInfo: userInfo)
            let displayTypeString = self.pushNotificationParser.getDisplayTypeIAM(userInfo: userInfo)
            let inactiveSessionDisplayString = self.pushNotificationParser.getInactiveSessionDisplayIAM(userInfo: userInfo)
            
            let type = self.getInAppMessageType(typeString: typeString)
            let displayType = self.getInAppMessageDisplayType(displayTypeString: displayTypeString)
            
            let (height, top, right, bottom, left, expirationTime) = self.InAppMessageOptionalParams(userInfo: userInfo)
            
            let inactiveSessionDisplay = self.getInAppMessageInactiveSessionDisplayType(inactiveSessionDisplayString: inactiveSessionDisplayString)
            
            let inAppMessageParams = InAppMessageParams(mcID: mcID, date: Date(), type: type, height: height, top: top, right: right, bottom: bottom, left: left, displayType: displayType, expirationTime: expirationTime, inactiveSessionDisplay: inactiveSessionDisplay)
            CoreDataManager.shared.inAppMessagesParam.setParamsToCoreDataInAppMessagesParam(inAppMessageParams: inAppMessageParams)
            
            self.fetchInAppMessage(mcID: mcID)
        }
    }
    
    func getInAppMessageType(typeString: String?) -> InAppMessageType {
        switch typeString {
        case InAppMessageType.modal.rawValue:
            return InAppMessageType.modal
        case InAppMessageType.fullscreen.rawValue:
            return InAppMessageType.fullscreen
        case InAppMessageType.banner_up.rawValue:
            return InAppMessageType.banner_up
        case InAppMessageType.banner_bottom.rawValue:
            return InAppMessageType.banner_bottom
        default:
            return InAppMessageType.modal
        }
    }
    
    func getInAppMessageDisplayType(displayTypeString: String?) -> InAppMessageDisplayType {
        switch displayTypeString {
        case InAppMessageDisplayType.displayImmediately.rawValue:
            return InAppMessageDisplayType.displayImmediately
        case InAppMessageDisplayType.displayOnAppOpenEvent.rawValue:
            return InAppMessageDisplayType.displayOnAppOpenEvent
        default:
            return InAppMessageDisplayType.displayImmediately
        }
    }
    
    func getInAppMessageInactiveSessionDisplayType(inactiveSessionDisplayString: String?) -> InAppMessageInactiveSessionDisplayType {
        switch inactiveSessionDisplayString {
        case InAppMessageInactiveSessionDisplayType.shownInAppMessage.rawValue:
            return InAppMessageInactiveSessionDisplayType.shownInAppMessage
        case InAppMessageInactiveSessionDisplayType.hideInAppMessage.rawValue:
            return InAppMessageInactiveSessionDisplayType.hideInAppMessage
        default:
            return InAppMessageInactiveSessionDisplayType.shownInAppMessage
        }
    }
    
    private func InAppMessageOptionalParams(userInfo: [AnyHashable : Any]) -> (Int16, Int16, Int16, Int16, Int16, Date?) {
        var height = Int16(20)
        var top = Int16(15)
        var right = Int16(10)
        var bottom = Int16(20)
        var left = Int16(10)
        var expirationTime: Date?
        
        if let userInfoHeight = userInfo["height"] as? Int16 {
            height = userInfoHeight
        }
        
        if let userInfoTop = userInfo["top"] as? Int16 {
            top = userInfoTop
        }
        
        if let userInfoRight = userInfo["right"] as? Int16 {
            right = userInfoRight
        }
        
        if let userInfoBottom = userInfo["bottom"] as? Int16 {
            bottom = userInfoBottom
        }
        
        if let userInfoLeft = userInfo["left"] as? Int16 {
            left = userInfoLeft
        }
        
        if let timestamp = self.pushNotificationParser.getExpirationTimeIAM(userInfo: userInfo) {
            expirationTime = CordialDateFormatter().getDateFromTimestamp(timestamp: timestamp)
        }
        
        return (height, top, right, bottom, left, expirationTime)
    }
    
    func fetchInAppMessage(mcID: String) {
        if ReachabilityManager.shared.isConnectedToInternet {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Fetching IAM with mcID: [%{public}@]", log: OSLog.cordialInAppMessage, type: .info, mcID)
            }
            
            if InternalCordialAPI().getCurrentJWT() != nil {
                InAppMessage().getInAppMessage(mcID: mcID)
            } else {
                let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
                self.systemErrorHandler(mcID: mcID, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            }
        } else {
            CoreDataManager.shared.inAppMessagesQueue.setMcIdToCoreDataInAppMessagesQueue(mcID: mcID)
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Fetching IAM failed. Saved to retry later. mcID: [%{public}@] Error: [No Internet connection]", log: OSLog.cordialInAppMessage, type: .info, mcID)
            }
        }
    }
    
    func completionHandler(inAppMessageData: InAppMessageData) {
        DispatchQueue.main.async {
            CoreDataManager.shared.inAppMessagesCache.setInAppMessageDataToCoreData(inAppMessageData: inAppMessageData)
            
            if UIApplication.shared.applicationState == .active {
                switch inAppMessageData.displayType {
                case InAppMessageDisplayType.displayOnAppOpenEvent:
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                        os_log("Save %{public}@ IAM with mcID: [%{public}@]", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
                    }
                case InAppMessageDisplayType.displayImmediately:
                    if InAppMessageProcess.shared.isAvailableInAppMessage(inAppMessageData: inAppMessageData) {
                        InAppMessageProcess.shared.showInAppMessage(inAppMessageData: inAppMessageData)
                    } else {
                        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                            os_log("Failed showing %{public}@ IAM with mcID: [%{public}@]. Error: [Live time has expired]", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
                        }
                    }
                }
            } else {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Save %{public}@ IAM with mcID: [%{public}@]", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
                }
            }
        }
    }
    
    func systemErrorHandler(mcID: String, error: ResponseError) {
        CoreDataManager.shared.inAppMessagesQueue.setMcIdToCoreDataInAppMessagesQueue(mcID: mcID)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Fetching IAM failed. Saved to retry later. mcID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialInAppMessage, type: .info, mcID, error.message)
        }
    }
    
    func logicErrorHandler(mcID: String, error: ResponseError) {
        NotificationCenter.default.post(name: .cordialInAppMessageLogicError, object: error)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("Fetching IAM failed. Will not retry. mcID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialInAppMessage, type: .error, mcID, error.message)
        }
    }
}

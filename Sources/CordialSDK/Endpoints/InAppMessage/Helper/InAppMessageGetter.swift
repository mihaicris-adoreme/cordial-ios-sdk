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
            self.setInAppMessageParamsToCoreData(userInfo: userInfo)
            self.fetchInAppMessage(mcID: mcID)
        }
    }
    
    func setInAppMessageParamsToCoreData(userInfo: [AnyHashable : Any]) {
        if let mcID = self.pushNotificationParser.getMcID(userInfo: userInfo) {
            let typeString = self.pushNotificationParser.getTypeIAM(userInfo: userInfo)
            let displayTypeString = self.pushNotificationParser.getDisplayTypeIAM(userInfo: userInfo)
            let inactiveSessionDisplayString = self.pushNotificationParser.getInactiveSessionDisplayIAM(userInfo: userInfo)
            
            let type = self.getInAppMessageType(typeString: typeString)
            let displayType = self.getInAppMessageDisplayType(displayTypeString: displayTypeString)
            
            let (height, top, right, bottom, left, expirationTime) = self.InAppMessageOptionalParams(userInfo: userInfo)
            
            let inactiveSessionDisplay = self.getInAppMessageInactiveSessionDisplayType(inactiveSessionDisplayString: inactiveSessionDisplayString)
            
            let inAppMessageParams = InAppMessageParams(mcID: mcID, date: Date(), type: type, height: height, top: top, right: right, bottom: bottom, left: left, displayType: displayType, expirationTime: expirationTime, inactiveSessionDisplay: inactiveSessionDisplay)
            
            CoreDataManager.shared.inAppMessagesParam.setParamsToCoreDataInAppMessagesParam(inAppMessagesParams: [inAppMessageParams])
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
        var (height, top, right, bottom, left) = self.InAppMessageOptionalParamsDefaultValues()
        var expirationTime: Date?
        
        if let userInfoHeight = self.pushNotificationParser.getBannerHeightIAM(userInfo: userInfo) {
            height = userInfoHeight
        }
        
        if let userInfoTop = self.pushNotificationParser.getModalTopMarginIAM(userInfo: userInfo) {
            top = userInfoTop
        }
        
        if let userInfoRight = self.pushNotificationParser.getModalRightMarginIAM(userInfo: userInfo) {
            right = userInfoRight
        }
        
        if let userInfoBottom = self.pushNotificationParser.getModalBottomMarginIAM(userInfo: userInfo) {
            bottom = userInfoBottom
        }
        
        if let userInfoLeft = self.pushNotificationParser.getModalLeftMarginIAM(userInfo: userInfo) {
            left = userInfoLeft
        }
        
        if let expirationTimeTimestamp = self.pushNotificationParser.getExpirationTimeIAM(userInfo: userInfo) {
            expirationTime = CordialDateFormatter().getDateFromTimestamp(timestamp: expirationTimeTimestamp)
        }
        
        return (height, top, right, bottom, left, expirationTime)
    }
    
    func InAppMessageOptionalParamsDefaultValues() -> (Int16, Int16, Int16, Int16, Int16) {
        let height = Int16(20)
        let top = Int16(15)
        let right = Int16(10)
        let bottom = Int16(20)
        let left = Int16(10)
        
        return (height, top, right, bottom, left)
    }
    
    func fetchInAppMessage(mcID: String) {
        if InternalCordialAPI().isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                if InternalCordialAPI().getCurrentJWT() != nil {
                    
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                        os_log("Fetching IAM with mcID: [%{public}@]", log: OSLog.cordialInAppMessage, type: .info, mcID)
                    }
                    
                    InAppMessage().getInAppMessage(mcID: mcID)
                } else {
                    let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
                    self.systemErrorHandler(mcID: mcID, error: responseError)
                    
                    SDKSecurity.shared.updateJWT()
                }
            } else {
                let responseError = ResponseError(message: "No Internet connection", statusCode: nil, responseBody: nil, systemError: nil)
                self.systemErrorHandler(mcID: mcID, error: responseError)
            }
        } else {
            let responseError = ResponseError(message: "User no login", statusCode: nil, responseBody: nil, systemError: nil)
            self.systemErrorHandler(mcID: mcID, error: responseError)
        }
    }
    
    func completionHandler(inAppMessageData: InAppMessageData) {
        InAppMessage().prepareAndShowInAppMessage(inAppMessageData: inAppMessageData)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            guard let htmlData = inAppMessageData.html.data(using: .utf8) else { return }
            let payloadSize = API.sizeFormatter(data: htmlData, formatter: .useAll)
            
            os_log("IAM with mcID: [%{public}@] has been successfully fetch. Payload size: %{public}@.", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.mcID, payloadSize)
        }
    }
    
    func systemErrorHandler(mcID: String, error: ResponseError) {
        ThreadQueues.shared.queueInAppMessage.sync(flags: .barrier) {
            CoreDataManager.shared.inAppMessagesQueue.setMcIDsToCoreDataInAppMessagesQueue(mcIDs: [mcID])
        }
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Fetching IAM failed. Saved to retry later. mcID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialInAppMessage, type: .info, mcID, error.message)
        }
    }
    
    func logicErrorHandler(mcID: String, error: ResponseError) {
        InAppMessageProcess.shared.deleteInAppMessageFromCoreDataByMcID(mcID: mcID)
        
        NotificationCenter.default.post(name: .cordialInAppMessageLogicError, object: error)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("Fetching IAM failed. Will not retry. mcID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialInAppMessage, type: .error, mcID, error.message)
        }
    }
}

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
                os_log("Fetching IAM failed. Saved to retry later. Error: [No Internet connection]", log: OSLog.cordialInAppMessage, type: .info)
            }
        }
    }
    
    func completionHandler(inAppMessageData: InAppMessageData) {
        DispatchQueue.main.async {
            if UIApplication.shared.applicationState == .active {
                switch inAppMessageData.displayType {
                case InAppMessageDisplayType.displayOnAppOpenEvent:
                    CoreDataManager.shared.inAppMessagesCache.setInAppMessageDataToCoreData(inAppMessageData: inAppMessageData)
                    
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
                CoreDataManager.shared.inAppMessagesCache.setInAppMessageDataToCoreData(inAppMessageData: inAppMessageData)
                
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Save %{public}@ IAM with mcID: [%{public}@]", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
                }
            }
        }
    }
    
    func systemErrorHandler(mcID: String, error: ResponseError) {
        CoreDataManager.shared.inAppMessagesQueue.setMcIdToCoreDataInAppMessagesQueue(mcID: mcID)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Fetching IAM failed. Saved to retry later. Error: [%{public}@]", log: OSLog.cordialInAppMessage, type: .info, error.message)
        }
    }
    
    func logicErrorHandler(error: ResponseError) {
        NotificationCenter.default.post(name: .cordialInAppMessageLogicError, object: error)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("Fetching IAM failed. Will not retry. For viewing exact error see .cordialInAppMessageLogicError notification in notification center.", log: OSLog.cordialInAppMessage, type: .error)
        }
    }
}

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
            let inAppMessage = InAppMessage()
            
            os_log("Fetching IAM with mcID: [%{public}@]", log: OSLog.cordialFetchInAppMessage, type: .info, mcID)
            
            inAppMessage.getInAppMessage(mcID: mcID)
        } else {
            CoreDataManager.shared.inAppMessagesQueue.setMcIdToCoreDataInAppMessagesQueue(mcID: mcID)
            os_log("Fetching IAM failed. Saved to retry later. Error: [No Internet connection.]", log: OSLog.cordialFetchInAppMessage, type: .info)
        }
    }
    
    func completionHandler(inAppMessageData: InAppMessageData) {
        DispatchQueue.main.async {
            if UIApplication.shared.applicationState == .active {
                switch inAppMessageData.displayType {
                case InAppMessageDisplayType.appOpenEvent:
                    CoreDataManager.shared.inAppMessagesCache.setInAppMessageDataToCoreData(inAppMessageData: inAppMessageData)
                    os_log("Save %{public}@ IAM with mcID: [%{public}@]", log: OSLog.cordialFetchInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
                case InAppMessageDisplayType.immediately:
                    InAppMessageProcess.shared.showInAppMessage(inAppMessageData: inAppMessageData)
                }
            } else {
                CoreDataManager.shared.inAppMessagesCache.setInAppMessageDataToCoreData(inAppMessageData: inAppMessageData)
                os_log("Save %{public}@ IAM with mcID: [%{public}@]", log: OSLog.cordialFetchInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
            }
        }
    }
    
    func systemErrorHandler(mcID: String, error: ResponseError) {
        CoreDataManager.shared.inAppMessagesQueue.setMcIdToCoreDataInAppMessagesQueue(mcID: mcID)
        os_log("Fetching IAM failed. Saved to retry later. Error: [%{public}@]", log: OSLog.cordialFetchInAppMessage, type: .info, error.message)
    }
    
    func logicErrorHandler(error: ResponseError) {
        NotificationCenter.default.post(name: .cordialFetchInAppMessageLogicError, object: error)
        os_log("Fetching IAM failed. Will not retry. For viewing exact error see .cordialFetchInAppMessageLogicError notification in notification center.", log: OSLog.cordialFetchInAppMessage, type: .info)
    }
}

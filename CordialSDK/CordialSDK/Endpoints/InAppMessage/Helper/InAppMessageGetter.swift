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
            
            inAppMessage.getInAppMessage(mcID: mcID,
                onSuccess: { inAppMessageData in
                    switch inAppMessageData.type {
                    case InAppMessageType.modal:
                        CoreDataManager.shared.inAppMessagesCache.setInAppMessageDataToCoreData(inAppMessageData: inAppMessageData)
                        os_log("Save %{public}@ IAM with mcID: [%{public}@]", log: OSLog.cordialFetchInAppMessage, type: .info, inAppMessageData.type.rawValue, mcID)
                    case InAppMessageType.fullscreen:
                        CoreDataManager.shared.inAppMessagesCache.setInAppMessageDataToCoreData(inAppMessageData: inAppMessageData)
                        os_log("Save %{public}@ IAM with mcID: [%{public}@]", log: OSLog.cordialFetchInAppMessage, type: .info, inAppMessageData.type.rawValue, mcID)
                    case InAppMessageType.banner:
                        CordialAPI().showBanerInAppMessage(inAppMessageData: inAppMessageData)
                        os_log("Showing %{public}@ IAM with mcID: [%{public}@]", log: OSLog.cordialFetchInAppMessage, type: .info, inAppMessageData.type.rawValue, mcID)
                    }
                }, systemError: { error in
                    CoreDataManager.shared.inAppMessagesQueue.setMcIdToCoreDataInAppMessagesQueue(mcID: mcID)
                    os_log("Fetching IAM failed. Saved to retry later. Error: [%{public}@]", log: OSLog.cordialFetchInAppMessage, type: .info, error.message)
                }, logicError: { error in
                    NotificationCenter.default.post(name: .cordialFetchInAppMessageLogicError, object: error)
                    os_log("Fetching IAM failed. Will not retry. For viewing exact error see .fetchInAppMessageLogicError notification in notification center.", log: OSLog.cordialFetchInAppMessage, type: .info)
                }
            )
        } else {
            CoreDataManager.shared.inAppMessagesQueue.setMcIdToCoreDataInAppMessagesQueue(mcID: mcID)
            os_log("Fetching IAM failed. Saved to retry later. Error: [No Internet connection.]", log: OSLog.cordialFetchInAppMessage, type: .info)
        }
    }
}

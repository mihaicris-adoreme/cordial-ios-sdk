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
            
            os_log("Fetching IAM with mcID: [%{public}@]", log: OSLog.fetchInAppMessage, type: .info, mcID)
            
            inAppMessage.getInAppMessage(mcID: mcID,
                onSuccess: { html in
                    let inAppMessageData = InAppMessageData(mcID: mcID, html: html)
                    CoreDataManager.shared.inAppMessagesCache.setInAppMessageDataToCoreData(inAppMessageData: inAppMessageData)
                    os_log("Save IAM with mcID: [%{public}@]", log: OSLog.fetchInAppMessage, type: .info, mcID)
                }, systemError: { error in
                    CoreDataManager.shared.inAppMessagesQueue.setMcIdToCoreDataInAppMessagesQueue(mcID: mcID)
                    os_log("Fetching IAM failed. Saved to retry later.", log: OSLog.fetchInAppMessage, type: .info)
                }, logicError: { error in
                    NotificationCenter.default.post(name: .fetchInAppMessageLogicError, object: error)
                    os_log("Fetching IAM failed. Will not retry.", log: OSLog.fetchInAppMessage, type: .info)
                }
            )
        } else {
            CoreDataManager.shared.inAppMessagesQueue.setMcIdToCoreDataInAppMessagesQueue(mcID: mcID)
            os_log("Fetching IAM failed. Saved to retry later.", log: OSLog.fetchInAppMessage, type: .info)
        }
    }
    
}

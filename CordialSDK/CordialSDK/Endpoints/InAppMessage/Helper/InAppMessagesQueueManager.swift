//
//  InAppMessagesQueueManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/4/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class InAppMessagesQueueManager {
    
    func fetchInAppMessagesFromQueue() {
        let mcIDs = CoreDataManager.shared.inAppMessagesQueue.getMcIDsFromCoreDataInAppMessagesQueue()
        mcIDs.forEach { mcID in
            if let inAppMessageContent = CoreDataManager.shared.inAppMessageContentURL.getInAppMessageContentFromCoreDataByMcID(mcID: mcID),
               API.isValidExpirationDate(date: inAppMessageContent.expireDate) {
                    
                ThreadQueues.shared.queueFetchInAppMessageContent.sync(flags: .barrier) {
                    InAppMessageContentGetter().fetchInAppMessageContent(mcID: mcID, url: inAppMessageContent.url)
                }
            } else {
                InAppMessageGetter().fetchInAppMessage(mcID: mcID)
            }
        }
    }
    
}


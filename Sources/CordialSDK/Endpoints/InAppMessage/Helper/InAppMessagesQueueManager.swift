//
//  InAppMessagesQueueManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/4/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class InAppMessagesQueueManager {
    
    func fetchInAppMessageDataFromQueue() {
        if let mcID = CoreDataManager.shared.inAppMessagesQueue.fetchLatestInAppMessageID() {
            if let inAppMessageContent = CoreDataManager.shared.inAppMessageContentURL.fetchInAppMessageContent(mcID: mcID),
               API.isValidExpirationDate(date: inAppMessageContent.expireDate) {
                    
                InAppMessageContentGetter().fetchInAppMessageContent(mcID: mcID, url: inAppMessageContent.url)
            } else {
                InAppMessageGetter().fetchInAppMessage(mcID: mcID)
            }
        }
    }
    
}


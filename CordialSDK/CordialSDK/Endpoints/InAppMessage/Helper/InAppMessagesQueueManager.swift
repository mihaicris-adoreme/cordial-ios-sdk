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
        ThrottlerManager.shared.fetchInAppMessages.throttle {
            let mcIDs = CoreDataManager.shared.inAppMessagesQueue.getMcIDsFromCoreDataInAppMessagesQueue()
            mcIDs.forEach { mcID in
                InAppMessageGetter().fetchInAppMessage(mcID: mcID)
            }
        }
    }
    
}


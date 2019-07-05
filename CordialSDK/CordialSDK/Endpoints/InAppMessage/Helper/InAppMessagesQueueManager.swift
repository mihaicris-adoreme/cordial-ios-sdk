//
//  InAppMessagesQueueManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/4/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class InAppMessagesQueueManager {
    
    func fetchInAppMessagesFromQueue() {
        let mcIDs = CoreDataManager.shared.inAppMessagesQueue.getMcIDsFromCoreDataInAppMessagesQueue()
        mcIDs.forEach { mcID in
            InAppMessageGetter().fetchInAppMessage(mcID: mcID)
        }
    }
    
}


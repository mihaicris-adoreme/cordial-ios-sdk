//
//  CustomEventsSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class CustomEventsSender {
    
    func sendCustomEvents(sendCustomEventRequests: [SendCustomEventRequest]) {
        if ReachabilityManager.shared.isConnectedToInternet && CordialAPI().getContactPrimaryKey() != nil {
            let sendCustomEvents = SendCustomEvents()
            
            os_log("Sending events:", log: OSLog.sendCustomEvents, type: .info)
            sendCustomEventRequests.forEach({ sendCustomEventRequest in
                os_log("[%{public}@]: [%{public}@]", log: OSLog.sendCustomEvents, type: .info, sendCustomEventRequest.timestamp, sendCustomEventRequest.eventName)
            })
            
            sendCustomEvents.sendCustomEvents(sendCustomEventRequests: sendCustomEventRequests,
                onSuccess: { result in
                    os_log("Events sent:", log: OSLog.sendCustomEvents, type: .info)
                    sendCustomEventRequests.forEach({ sendCustomEventRequest in
                        os_log("[%{public}@]: [%{public}@]", log: OSLog.sendCustomEvents, type: .info, sendCustomEventRequest.timestamp, sendCustomEventRequest.eventName)
                    })
                }, systemError: { error in
                    CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequests)
                    os_log("Sending custom events failed. Saved to retry later. Error: [%{public}@]", log: OSLog.sendCustomEvents, type: .info, error.message)
                }, logicError: { error in
                    NotificationCenter.default.post(name: .sendCustomEventsLogicError, object: error)
                    os_log("Sending custom events failed. Will not retry. For viewing exact error see .sendCustomEventsLogicError notification in notification center.", log: OSLog.sendCustomEvents, type: .info)
                }
            )
        } else {
            CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequests)
            
            if CordialAPI().getContactPrimaryKey() == nil {
                os_log("Sending custom events failed. Saved to retry later. Error: [primaryKey is nil]", log: OSLog.sendCustomEvents, type: .info)
            } else {
                os_log("Sending custom events failed. Saved to retry later. Error: [No Internet connection.]", log: OSLog.sendCustomEvents, type: .info)
            }
        }
    }

}

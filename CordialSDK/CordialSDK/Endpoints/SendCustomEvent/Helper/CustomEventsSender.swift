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
            
            os_log("Sending events:", log: OSLog.cordialSendCustomEvents, type: .info)
            sendCustomEventRequests.forEach({ sendCustomEventRequest in
                os_log("[%{public}@]: [%{public}@]", log: OSLog.cordialSendCustomEvents, type: .info, sendCustomEventRequest.timestamp, sendCustomEventRequest.eventName)
            })
            
            sendCustomEvents.sendCustomEvents(sendCustomEventRequests: sendCustomEventRequests,
                onSuccess: { result in
                    os_log("Events sent:", log: OSLog.cordialSendCustomEvents, type: .info)
                    sendCustomEventRequests.forEach({ sendCustomEventRequest in
                        os_log("[%{public}@]: [%{public}@]", log: OSLog.cordialSendCustomEvents, type: .info, sendCustomEventRequest.timestamp, sendCustomEventRequest.eventName)
                    })
                }, systemError: { error in
                    CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequests)
                    os_log("Sending custom events failed. Saved to retry later. Error: [%{public}@]", log: OSLog.cordialSendCustomEvents, type: .info, error.message)
                }, logicError: { error in
                    NotificationCenter.default.post(name: .cordialSendCustomEventsLogicError, object: error)
                    os_log("Sending custom events failed. Will not retry. Error: [%{public}@]", log: OSLog.cordialSendCustomEvents, type: .info, error.message)
                }
            )
        } else {
            CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequests)
            
            if CordialAPI().getContactPrimaryKey() == nil {
                os_log("Sending custom events failed. Saved to retry later. Error: [primaryKey is nil]", log: OSLog.cordialSendCustomEvents, type: .info)
            } else {
                os_log("Sending custom events failed. Saved to retry later. Error: [No Internet connection.]", log: OSLog.cordialSendCustomEvents, type: .info)
            }
        }
    }

}

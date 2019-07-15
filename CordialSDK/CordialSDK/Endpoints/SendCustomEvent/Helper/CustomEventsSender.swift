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
            
            os_log("Sending custom events:", log: OSLog.cordialSendCustomEvents, type: .info)
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
                    os_log("Sending some custom events failed. Will not retry. For viewing exact error see .sendCustomEventsLogicError notification in notification center.", log: OSLog.cordialSendCustomEvents, type: .info)

                    if let responseBody = error.responseBody {
                        let sendCustomEventRequestsWithoutBrokenEvents = self.getCustomEventRequestsWithoutBrokenEvents(sendCustomEventRequests: sendCustomEventRequests, responseBody: responseBody)
                        if sendCustomEventRequestsWithoutBrokenEvents.count > 0 {
                            CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequestsWithoutBrokenEvents)
                            os_log("Saved valid events to retry later.", log: OSLog.cordialSendCustomEvents, type: .info)
                        }
                    }
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

    private func getCustomEventRequestsWithoutBrokenEvents(sendCustomEventRequests: [SendCustomEventRequest], responseBody: String) -> [SendCustomEventRequest] {
        let errorIDs = self.getErrorIDs(responseBody: responseBody)
        
        var mutableSendCustomEventRequests = sendCustomEventRequests
        
        errorIDs.forEach { errorID in
            mutableSendCustomEventRequests.remove(at: errorID)
        }
        
        return mutableSendCustomEventRequests
    }
    
    private func getErrorIDs(responseBody: String) -> [Int] {
        var errorIDs = [Int]()
        
        do {
            if let responseBodyData = responseBody.data(using: .utf8) {
                let responseBodyJSON = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as! [String: AnyObject]
                if let errorsJSON = responseBodyJSON["error"]?["errors"] as? [String: AnyObject] {
                    let errors = errorsJSON.keys.map { $0 }
                    errors.forEach { error in
                        if let stringID = error.components(separatedBy: ".").first, let intID = Int(stringID) {
                            errorIDs.append(intID)
                        }
                    }
                }
            }
        } catch let error as NSError {
            os_log("[%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
        }
        
        return errorIDs
    }
}

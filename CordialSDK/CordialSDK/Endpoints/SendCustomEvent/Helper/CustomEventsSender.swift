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
        if ReachabilityManager.shared.isConnectedToInternet {
            self.sendCustomEventsIfUserLoggedIn(sendCustomEventRequests: sendCustomEventRequests)
        } else {
            CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequests)
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Sending custom events failed. Saved to retry later. Error: [No Internet connection]", log: OSLog.cordialSendCustomEvents, type: .info)
            }
        }
    }
    
    func completionHandler(sendCustomEventRequests: [SendCustomEventRequest]) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Events sent:", log: OSLog.cordialSendCustomEvents, type: .info)
            sendCustomEventRequests.forEach({ sendCustomEventRequest in
                os_log("[%{public}@]: [%{public}@]", log: OSLog.cordialSendCustomEvents, type: .info, sendCustomEventRequest.timestamp, sendCustomEventRequest.eventName)
            })
        }
    }
    
    func systemErrorHandler(sendCustomEventRequests: [SendCustomEventRequest], error: ResponseError) {
        CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequests)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Sending custom events failed. Saved to retry later. Error: [%{public}@]", log: OSLog.cordialSendCustomEvents, type: .info, error.message)
        }
    }
    
    func logicErrorHandler(sendCustomEventRequests: [SendCustomEventRequest], error: ResponseError) {
        NotificationCenter.default.post(name: .cordialSendCustomEventsLogicError, object: error)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Sending some custom events failed. Will not retry. For viewing exact error see .cordialSendCustomEventsLogicError notification in notification center.", log: OSLog.cordialSendCustomEvents, type: .info)
        }
        
        if let responseBody = error.responseBody {
            let sendCustomEventRequestsWithoutBrokenEvents = self.getCustomEventRequestsWithoutBrokenEvents(sendCustomEventRequests: sendCustomEventRequests, responseBody: responseBody)
            if sendCustomEventRequestsWithoutBrokenEvents.count > 0 {
                CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequestsWithoutBrokenEvents)
                
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Saved valid events to retry later", log: OSLog.cordialSendCustomEvents, type: .info)
                }
            }
        }
    }
    
    private func sendCustomEventsIfUserLoggedIn(sendCustomEventRequests: [SendCustomEventRequest]) {
        if CordialAPI().getContactPrimaryKey() != nil {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Sending custom events:", log: OSLog.cordialSendCustomEvents, type: .info)
                sendCustomEventRequests.forEach({ sendCustomEventRequest in
                    os_log("[%{public}@]: [%{public}@]", log: OSLog.cordialSendCustomEvents, type: .info, sendCustomEventRequest.timestamp, sendCustomEventRequest.eventName)
                })
            }
            
            if InternalCordialAPI().getCurrentJWT() != nil {
                SendCustomEvents().sendCustomEvents(sendCustomEventRequests: sendCustomEventRequests)
            } else {
                let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
                self.systemErrorHandler(sendCustomEventRequests: sendCustomEventRequests, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            }
        } else {
            CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequests)
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Sending custom events failed. Saved to retry later. Error: [primaryKey is nil]", log: OSLog.cordialSendCustomEvents, type: .info)
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
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
            }
        }
        
        return errorIDs
    }
}

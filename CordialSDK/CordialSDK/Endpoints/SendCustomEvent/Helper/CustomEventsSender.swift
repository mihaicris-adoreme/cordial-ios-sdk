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
    
    let sendCustomEvents = SendCustomEvents()
    
    func sendCustomEvents(sendCustomEventRequests: [SendCustomEventRequest]) {
        let eventNamesAndRequestIDs = self.getEventNamesAndRequestIDs(sendCustomEventRequests: sendCustomEventRequests)
        
        if ReachabilityManager.shared.isConnectedToInternet {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Sending custom events: { %{public}@ }", log: OSLog.cordialSendCustomEvents, type: .info, eventNamesAndRequestIDs)
                
                let payload = self.sendCustomEvents.getSendCustomEventsJSON(sendCustomEventRequests: sendCustomEventRequests)
                os_log("Payload: %{public}@", log: OSLog.cordialSendCustomEvents, type: .info, payload)
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
                os_log("Sending custom events { %{public}@ } failed. Saved to retry later. Error: [No Internet connection]", log: OSLog.cordialSendCustomEvents, type: .info, eventNamesAndRequestIDs)
            }
        }
    }
    
    func completionHandler(sendCustomEventRequests: [SendCustomEventRequest]) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            let eventNamesAndRequestIDs = self.getEventNamesAndRequestIDs(sendCustomEventRequests: sendCustomEventRequests)
            os_log("Custom events { %{public}@ } have been sent", log: OSLog.cordialSendCustomEvents, type: .info, eventNamesAndRequestIDs)
        }
    }
    
    func systemErrorHandler(sendCustomEventRequests: [SendCustomEventRequest], error: ResponseError) {
        CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequests)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            let eventNamesAndRequestIDs = self.getEventNamesAndRequestIDs(sendCustomEventRequests: sendCustomEventRequests)
            os_log("Sending custom events { %{public}@ } failed. Saved to retry later. Error: [%{public}@]", log: OSLog.cordialSendCustomEvents, type: .info, eventNamesAndRequestIDs, error.message)
        }
    }
    
    func logicErrorHandler(sendCustomEventRequests: [SendCustomEventRequest], error: ResponseError) {
        NotificationCenter.default.post(name: .cordialSendCustomEventsLogicError, object: error)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            let eventNamesAndRequestIDs = self.getEventNamesAndRequestIDs(sendCustomEventRequests: sendCustomEventRequests)
            os_log("Sending some custom events { %{public}@ } failed. Will not retry. Error: [%{public}@]", log: OSLog.cordialSendCustomEvents, type: .error, eventNamesAndRequestIDs, error.message)
        }
        
        if let responseBody = error.responseBody {
            let sendCustomEventRequestsWithoutBrokenEvents = self.getCustomEventRequestsWithoutBrokenEvents(sendCustomEventRequests: sendCustomEventRequests, responseBody: responseBody)
            if sendCustomEventRequestsWithoutBrokenEvents.count > 0 {
                CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequestsWithoutBrokenEvents)
                
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    let eventNamesAndRequestIDsWithoutBrokenEvents = self.getEventNamesAndRequestIDs(sendCustomEventRequests: sendCustomEventRequestsWithoutBrokenEvents)
                    os_log("Saved valid events { %{public}@ } to retry later", log: OSLog.cordialSendCustomEvents, type: .info, eventNamesAndRequestIDsWithoutBrokenEvents)
                }
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
    
    internal func getEventNamesAndRequestIDs(sendCustomEventRequests: [SendCustomEventRequest]) -> String {
        var eventNamesAndRequestIDsContainer = [String]()
        sendCustomEventRequests.forEach({ sendCustomEventRequest in
            eventNamesAndRequestIDsContainer.append("[ eventName: \(sendCustomEventRequest.eventName), eventID: \(sendCustomEventRequest.requestID) ]")
        })
        let eventNamesAndRequestIDs = eventNamesAndRequestIDsContainer.joined(separator: ", ")
        
        return eventNamesAndRequestIDs
    }
}

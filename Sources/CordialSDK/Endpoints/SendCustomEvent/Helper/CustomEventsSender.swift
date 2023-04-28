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
        
        if InternalCordialAPI().isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                self.sendCustomEventsData(sendCustomEventRequests: sendCustomEventRequests)
            } else {
                // Function has been called through barrier queue. No need additional barrier.
                CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequests)
                
                CordialApiConfiguration.shared.osLogManager.logging("Sending events { %{public}@ } failed. Saved to retry later. Error: [No Internet connection]", log: OSLog.cordialSendCustomEvents, type: .info, eventNamesAndRequestIDs)
            }
        } else {
            // Function has been called through barrier queue. No need additional barrier.
            CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequests)
            
            CordialApiConfiguration.shared.osLogManager.logging("Sending events { %{public}@ } failed. Saved to retry later. Error: [User no login]", log: OSLog.cordialSendCustomEvents, type: .info, eventNamesAndRequestIDs)
        }
    }
    
    private func sendCustomEventsData(sendCustomEventRequests: [SendCustomEventRequest]) {
        if InternalCordialAPI().getCurrentJWT() != nil {
            let eventNamesAndRequestIDs = self.getEventNamesAndRequestIDs(sendCustomEventRequests: sendCustomEventRequests)
            CordialApiConfiguration.shared.osLogManager.logging("Sending events: { %{public}@ }", log: OSLog.cordialSendCustomEvents, type: .info, eventNamesAndRequestIDs)
                
            let payload = self.sendCustomEvents.getSendCustomEventsJSON(sendCustomEventRequests: sendCustomEventRequests)
            CordialApiConfiguration.shared.osLogManager.logging("Payload: %{public}@", log: OSLog.cordialSendCustomEvents, type: .info, payload)
            
            SendCustomEvents().sendCustomEvents(sendCustomEventRequests: sendCustomEventRequests)
        } else {
            let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
            self.systemErrorHandler(sendCustomEventRequests: sendCustomEventRequests, error: responseError)
            
            SDKSecurity.shared.updateJWT()
        }
    }
    
    func completionHandler(sendCustomEventRequests: [SendCustomEventRequest]) {
        let eventNamesAndRequestIDs = self.getEventNamesAndRequestIDs(sendCustomEventRequests: sendCustomEventRequests)
        CordialApiConfiguration.shared.osLogManager.logging("Events { %{public}@ } have been sent", log: OSLog.cordialSendCustomEvents, type: .info, eventNamesAndRequestIDs)
    }
    
    func systemErrorHandler(sendCustomEventRequests: [SendCustomEventRequest], error: ResponseError) {
        CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequests)
        
        let eventNamesAndRequestIDs = self.getEventNamesAndRequestIDs(sendCustomEventRequests: sendCustomEventRequests)
        CordialApiConfiguration.shared.osLogManager.logging("Sending events { %{public}@ } failed. Saved to retry later. Error: [%{public}@]", log: OSLog.cordialSendCustomEvents, type: .info, eventNamesAndRequestIDs, error.message)
    }

    func logicErrorHandler(sendCustomEventRequests: [SendCustomEventRequest], error: ResponseError) {
        NotificationCenter.default.post(name: .cordialSendCustomEventsLogicError, object: error)
        
        let eventNamesAndRequestIDs = self.getEventNamesAndRequestIDs(sendCustomEventRequests: sendCustomEventRequests)
        CordialApiConfiguration.shared.osLogManager.logging("Sending some events { %{public}@ } failed. Will not retry. Error: [%{public}@]", log: OSLog.cordialSendCustomEvents, type: .error, eventNamesAndRequestIDs, error.message)
        
        if error.statusCode == 422, let responseBody = error.responseBody {
            let sendCustomEventRequestsWithoutBrokenEvents = self.getCustomEventRequestsWithoutBrokenEvents(sendCustomEventRequests: sendCustomEventRequests, responseBody: responseBody)
            if !sendCustomEventRequestsWithoutBrokenEvents.isEmpty {
                
                self.sendCustomEvents(sendCustomEventRequests: sendCustomEventRequestsWithoutBrokenEvents)
                
                let eventNamesAndRequestIDsWithoutBrokenEvents = self.getEventNamesAndRequestIDs(sendCustomEventRequests: sendCustomEventRequestsWithoutBrokenEvents)
                CordialApiConfiguration.shared.osLogManager.logging("Sending again valid events { %{public}@ }", log: OSLog.cordialSendCustomEvents, type: .info, eventNamesAndRequestIDsWithoutBrokenEvents)
            }
        }
    }

    private func getCustomEventRequestsWithoutBrokenEvents(sendCustomEventRequests: [SendCustomEventRequest], responseBody: String) -> [SendCustomEventRequest] {
        let errorIDs = self.getErrorIDs(responseBody: responseBody)
        
        let validEnumeratedSendCustomEventRequests = sendCustomEventRequests.enumerated().filter {
            !errorIDs.contains($0.offset)
        }
        
        var mutableSendCustomEventRequests = [SendCustomEventRequest]()
        validEnumeratedSendCustomEventRequests.forEach { (offset, sendCustomEventRequest) in
            mutableSendCustomEventRequests.append(sendCustomEventRequest)
        }
        
        return mutableSendCustomEventRequests
    }
    
    private func getErrorIDs(responseBody: String) -> [Int] {
        var errorIDs = [Int]()
        
        do {
            if let responseBodyData = responseBody.data(using: .utf8), let responseBodyJSON = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as? [String: AnyObject] {
                if let errorsJSON = responseBodyJSON["error"]?["errors"] as? [String: AnyObject] {
                    let errors = errorsJSON.keys.map { $0 }
                    errors.forEach { error in
                        if let stringID = error.components(separatedBy: ".").first, let intID = Int(stringID), !errorIDs.contains(intID) {
                            errorIDs.append(intID)
                        }
                    }
                }
            } else {
                CordialApiConfiguration.shared.osLogManager.logging("Failed decode response", log: OSLog.cordialSendCustomEvents, type: .error)
            }
        } catch let error {
            CordialApiConfiguration.shared.osLogManager.logging("Error: [%{public}@]", log: OSLog.cordialSendCustomEvents, type: .error, error.localizedDescription)
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
    
    internal func isEventNameHaveSystemPrefix(sendCustomEventRequest: SendCustomEventRequest) -> Bool {
        return sendCustomEventRequest.eventName.hasPrefix(API.SYSTEM_EVENT_PREFIX)
    }
}

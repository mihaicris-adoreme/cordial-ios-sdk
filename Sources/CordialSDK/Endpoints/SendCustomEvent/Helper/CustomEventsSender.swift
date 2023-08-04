//
//  CustomEventsSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class CustomEventsSender {
    
    let sendCustomEvents = SendCustomEvents()
    
    func sendCustomEvents(sendCustomEventRequests: [SendCustomEventRequest]) {
        let eventNamesAndRequestIDs = self.getEventNamesAndRequestIDs(sendCustomEventRequests: sendCustomEventRequests)
        
        if InternalCordialAPI().isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                self.sendCustomEventsData(sendCustomEventRequests: sendCustomEventRequests)
            } else {
                // Function has been called through barrier queue. No need additional barrier.
                CoreDataManager.shared.customEventRequests.putCustomEventRequests(sendCustomEventRequests: sendCustomEventRequests)
                
                LoggerManager.shared.info(message: "Sending events { \(eventNamesAndRequestIDs) } failed. Saved to retry later. Error: [No Internet connection]", category: "CordialSDKSendCustomEvents")
            }
        } else {
            // Function has been called through barrier queue. No need additional barrier.
            CoreDataManager.shared.customEventRequests.putCustomEventRequests(sendCustomEventRequests: sendCustomEventRequests)
            
            LoggerManager.shared.info(message: "Sending events { \(eventNamesAndRequestIDs) } failed. Saved to retry later. Error: [User no login]", category: "CordialSDKSendCustomEvents")
        }
    }
    
    private func sendCustomEventsData(sendCustomEventRequests: [SendCustomEventRequest]) {
        if InternalCordialAPI().getCurrentJWT() != nil {
            let eventNamesAndRequestIDs = self.getEventNamesAndRequestIDs(sendCustomEventRequests: sendCustomEventRequests)
            LoggerManager.shared.info(message: "Sending events: { \(eventNamesAndRequestIDs) }", category: "CordialSDKSendCustomEvents")
                
            let payload = self.sendCustomEvents.getSendCustomEventsJSON(sendCustomEventRequests: sendCustomEventRequests)
            LoggerManager.shared.info(message: "Payload: \(payload)", category: "CordialSDKSendCustomEvents")
            
            SendCustomEvents().sendCustomEvents(sendCustomEventRequests: sendCustomEventRequests)
        } else {
            let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
            self.systemErrorHandler(sendCustomEventRequests: sendCustomEventRequests, error: responseError)
            
            SDKSecurity.shared.updateJWT()
        }
    }
    
    func completionHandler(sendCustomEventRequests: [SendCustomEventRequest]) {
        CoreDataManager.shared.customEventRequests.removeCustomEventRequests(sendCustomEventRequests: sendCustomEventRequests)
        
        let eventNamesAndRequestIDs = self.getEventNamesAndRequestIDs(sendCustomEventRequests: sendCustomEventRequests)
        LoggerManager.shared.info(message: "Events { \(eventNamesAndRequestIDs) } have been sent", category: "CordialSDKSendCustomEvents")
    }
    
    func systemErrorHandler(sendCustomEventRequests: [SendCustomEventRequest], error: ResponseError) {
        CoreDataManager.shared.customEventRequests.putCustomEventRequests(sendCustomEventRequests: sendCustomEventRequests)
        
        let eventNamesAndRequestIDs = self.getEventNamesAndRequestIDs(sendCustomEventRequests: sendCustomEventRequests)
        LoggerManager.shared.info(message: "Sending events { \(eventNamesAndRequestIDs) } failed. Saved to retry later. Error: [\(error.message)]", category: "CordialSDKSendCustomEvents")
    }

    func logicErrorHandler(sendCustomEventRequests: [SendCustomEventRequest], error: ResponseError) {
        NotificationCenter.default.post(name: .cordialSendCustomEventsLogicError, object: error)
        
        let eventNamesAndRequestIDs = self.getEventNamesAndRequestIDs(sendCustomEventRequests: sendCustomEventRequests)
        LoggerManager.shared.error(message: "Sending some events { \(eventNamesAndRequestIDs) } failed. Will not retry. Error: [\(error.message)]", category: "CordialSDKSendCustomEvents")
        
        if error.statusCode == 422, let responseBody = error.responseBody {
            let sendCustomEventRequestsWithoutBrokenEvents = self.getCustomEventRequestsWithoutBrokenEvents(sendCustomEventRequests: sendCustomEventRequests, responseBody: responseBody)
            if !sendCustomEventRequestsWithoutBrokenEvents.isEmpty {
                
                let requestIDsWithoutBrokenEvents = sendCustomEventRequestsWithoutBrokenEvents.map { $0.requestID }
                var sendCustomEventRequestsWithBrokenEvents: [SendCustomEventRequest] = []
                sendCustomEventRequests.forEach { sendCustomEventRequest in
                    if !requestIDsWithoutBrokenEvents.contains(sendCustomEventRequest.requestID) {
                        sendCustomEventRequestsWithBrokenEvents.append(sendCustomEventRequest)
                    }
                }
                CoreDataManager.shared.customEventRequests.removeCustomEventRequests(sendCustomEventRequests: sendCustomEventRequestsWithBrokenEvents)
                
                let eventNamesAndRequestIDsWithoutBrokenEvents = self.getEventNamesAndRequestIDs(sendCustomEventRequests: sendCustomEventRequestsWithoutBrokenEvents)
                LoggerManager.shared.info(message: "Sending again valid events { \(eventNamesAndRequestIDsWithoutBrokenEvents) }", category: "CordialSDKSendCustomEvents")
                
                self.sendCustomEvents(sendCustomEventRequests: sendCustomEventRequestsWithoutBrokenEvents)
                
            } else {
                CoreDataManager.shared.customEventRequests.removeCustomEventRequests(sendCustomEventRequests: sendCustomEventRequests)
            }
        } else {
            CoreDataManager.shared.customEventRequests.removeCustomEventRequests(sendCustomEventRequests: sendCustomEventRequests)
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
                LoggerManager.shared.error(message: "Failed decode response", category: "CordialSDKSendCustomEvents")
            }
        } catch let error {
            LoggerManager.shared.error(message: "Error: [\(error.localizedDescription)]", category: "CordialSDKSendCustomEvents")
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

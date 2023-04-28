//
//  ContactLogoutSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/17/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class ContactLogoutSender {
    
    let sendContactLogout = SendContactLogout()
    
    func sendContactLogout(sendContactLogoutRequest: SendContactLogoutRequest) {
    
        let internalCordialAPI = InternalCordialAPI()
        
        internalCordialAPI.removeCurrentMcID()
        
        if internalCordialAPI.getPushNotificationToken() != nil {
            self.sendContactLogoutData(sendContactLogoutRequest: sendContactLogoutRequest)
        } else {
            CordialApiConfiguration.shared.osLogManager.logging("Sending contact logout failed. Request ID: [%{public}@] Error: [Device token is absent]", log: OSLog.cordialSendContactLogout, type: .info, sendContactLogoutRequest.requestID)
        }
    }
    
    private func sendContactLogoutData(sendContactLogoutRequest: SendContactLogoutRequest) {
        if ReachabilityManager.shared.isConnectedToInternet {
            if InternalCordialAPI().getCurrentJWT() != nil {
                
                CordialApiConfiguration.shared.osLogManager.logging("Sending contact logout. Request ID: [%{public}@]", log: OSLog.cordialSendContactLogout, type: .info, sendContactLogoutRequest.requestID)
                
                let payload = self.sendContactLogout.getSendContactLogoutJSON(sendContactLogoutRequest: sendContactLogoutRequest)
                CordialApiConfiguration.shared.osLogManager.logging("Payload: %{public}@", log: OSLog.cordialSendContactLogout, type: .info, payload)
                
                SendContactLogout().sendContactLogout(sendContactLogoutRequest: sendContactLogoutRequest)
                
            } else {
                let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
                self.systemErrorHandler(sendContactLogoutRequest: sendContactLogoutRequest, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            }
        } else {
            CoreDataManager.shared.contactLogoutRequest.setContactLogoutRequestToCoreData(sendContactLogoutRequest: sendContactLogoutRequest)
            
            CordialApiConfiguration.shared.osLogManager.logging("Sending contact logout failed. Saved to retry later. Request ID: [%{public}@] Error: [No Internet connection]", log: OSLog.cordialSendContactLogout, type: .info, sendContactLogoutRequest.requestID)
        }
    }
    
    func completionHandler(sendContactLogoutRequest: SendContactLogoutRequest) {
        CordialApiConfiguration.shared.osLogManager.logging("Contact logout has been sent. Request ID: [%{public}@]", log: OSLog.cordialSendContactLogout, type: .info, sendContactLogoutRequest.requestID)
    }
    
    func systemErrorHandler(sendContactLogoutRequest: SendContactLogoutRequest, error: ResponseError) {
        CoreDataManager.shared.contactLogoutRequest.setContactLogoutRequestToCoreData(sendContactLogoutRequest: sendContactLogoutRequest)
        
        CordialApiConfiguration.shared.osLogManager.logging("Sending contact logout failed. Saved to retry later. Request ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialSendContactLogout, type: .info, sendContactLogoutRequest.requestID, error.message)
    }
    
    func logicErrorHandler(sendContactLogoutRequest: SendContactLogoutRequest, error: ResponseError) {
        NotificationCenter.default.post(name: .cordialSendContactLogoutLogicError, object: error)
        
        CordialApiConfiguration.shared.osLogManager.logging("Sending contact logout failed. Will not retry. Request ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialSendContactLogout, type: .error, sendContactLogoutRequest.requestID, error.message)
    }
}


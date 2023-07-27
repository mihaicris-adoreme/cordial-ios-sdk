//
//  ContactLogoutSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/17/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class ContactLogoutSender {
    
    let sendContactLogout = SendContactLogout()
    
    func sendContactLogout(sendContactLogoutRequest: SendContactLogoutRequest) {
    
        let internalCordialAPI = InternalCordialAPI()
        
        internalCordialAPI.removeCurrentMcID()
        
        if internalCordialAPI.getPushNotificationToken() != nil {
            self.sendContactLogoutData(sendContactLogoutRequest: sendContactLogoutRequest)
        } else {
            LoggerManager.shared.info(message: "Sending contact logout failed. Request ID: [\(sendContactLogoutRequest.requestID)] Error: [Device token is absent]", category: "CordialSDKSendContactLogout")
        }
    }
    
    private func sendContactLogoutData(sendContactLogoutRequest: SendContactLogoutRequest) {
        if ReachabilityManager.shared.isConnectedToInternet {
            if InternalCordialAPI().getCurrentJWT() != nil {
                
                LoggerManager.shared.info(message: "Sending contact logout. Request ID: [\(sendContactLogoutRequest.requestID)]", category: "CordialSDKSendContactLogout")
                
                let payload = self.sendContactLogout.getSendContactLogoutJSON(sendContactLogoutRequest: sendContactLogoutRequest)
                LoggerManager.shared.info(message: "Payload: \(payload)", category: "CordialSDKSendContactLogout")
                
                SendContactLogout().sendContactLogout(sendContactLogoutRequest: sendContactLogoutRequest)
                
            } else {
                let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
                self.systemErrorHandler(sendContactLogoutRequest: sendContactLogoutRequest, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            }
        } else {
            CoreDataManager.shared.contactLogoutRequest.putContactLogoutRequest(sendContactLogoutRequest: sendContactLogoutRequest)
            
            LoggerManager.shared.info(message: "Sending contact logout failed. Saved to retry later. Request ID: [\(sendContactLogoutRequest.requestID)] Error: [No Internet connection]", category: "CordialSDKSendContactLogout")
        }
    }
    
    func completionHandler(sendContactLogoutRequest: SendContactLogoutRequest) {
        LoggerManager.shared.info(message: "Contact logout has been sent. Request ID: [\(sendContactLogoutRequest.requestID)]", category: "CordialSDKSendContactLogout")
    }
    
    func systemErrorHandler(sendContactLogoutRequest: SendContactLogoutRequest, error: ResponseError) {
        CoreDataManager.shared.contactLogoutRequest.putContactLogoutRequest(sendContactLogoutRequest: sendContactLogoutRequest)
        
        LoggerManager.shared.info(message: "Sending contact logout failed. Saved to retry later. Request ID: [\(sendContactLogoutRequest.requestID)] Error: [\(error.message)]", category: "CordialSDKSendContactLogout")
    }
    
    func logicErrorHandler(sendContactLogoutRequest: SendContactLogoutRequest, error: ResponseError) {
        NotificationCenter.default.post(name: .cordialSendContactLogoutLogicError, object: error)
        
        LoggerManager.shared.error(message: "Sending contact logout failed. Will not retry. Request ID: [\(sendContactLogoutRequest.requestID)] Error: [\(error.message)]", category: "CordialSDKSendContactLogout")
    }
}


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
    
    func sendContactLogout(sendContactLogoutRequest: SendContactLogoutRequest) {
        if ReachabilityManager.shared.isConnectedToInternet {
            os_log("Sending contact logout:", log: OSLog.cordialSendContactLogout, type: .info)
            os_log("Device ID: [%{public}@]", log: OSLog.cordialSendContactLogout, type: .info, sendContactLogoutRequest.deviceID)
            
            SendContactLogout().sendContactLogout(sendContactLogoutRequest: sendContactLogoutRequest)
        } else {
            CoreDataManager.shared.contactLogoutRequest.setContactLogoutRequestToCoreData(sendContactLogoutRequest: sendContactLogoutRequest)
            os_log("Sending contact logout failed. Saved to retry later. Error: [No Internet connection.]", log: OSLog.cordialSendContactLogout, type: .info)
        }
    }
    
    func completionHandler(sendContactLogoutRequest: SendContactLogoutRequest) {
        os_log("Contact logout sent:", log: OSLog.cordialSendContactLogout, type: .info)
        os_log("Device ID: [%{public}@]", log: OSLog.cordialSendContactLogout, type: .info, sendContactLogoutRequest.deviceID)
    }
    
    func systemErrorHandler(sendContactLogoutRequest: SendContactLogoutRequest, error: ResponseError) {
        CoreDataManager.shared.contactLogoutRequest.setContactLogoutRequestToCoreData(sendContactLogoutRequest: sendContactLogoutRequest)
        os_log("Sending contact logout failed. Saved to retry later. Error: [%{public}@]", log: OSLog.cordialSendContactLogout, type: .info, error.message)
    }
    
    func logicErrorHandler(error: ResponseError) {
        NotificationCenter.default.post(name: .cordialSendContactLogoutLogicError, object: error)
        os_log("Sending contact logout failed. Will not retry. For viewing exact error see .cordialSendContactLogoutLogicError notification in notification center.", log: OSLog.cordialSendContactLogout, type: .info)
    }
}


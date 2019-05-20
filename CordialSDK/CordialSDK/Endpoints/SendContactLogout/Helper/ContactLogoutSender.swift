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
        if ReachabilityManager.shared.isConnectedToInternet && CordialAPI().getContactPrimaryKey() != nil {
            let sendContactLogout = SendContactLogout()
            
            os_log("Sending contact logout:", log: OSLog.sendContactLogout, type: .info)
            os_log("Device ID: [%{PUBLIC}@]", log: OSLog.sendContactLogout, type: .info, sendContactLogoutRequest.deviceID)
            
            sendContactLogout.sendContactLogout(sendContactLogoutRequest: sendContactLogoutRequest,
                onSuccess: { result in
                    os_log("Contact logout sent:", log: OSLog.sendContactLogout, type: .info)
                    os_log("Device ID: [%{PUBLIC}@]", log: OSLog.sendContactLogout, type: .info, sendContactLogoutRequest.deviceID)
                }, systemError: { error in
                    CoreDataManager.shared.contactLogoutRequest.setContactLogoutRequestToCoreData(sendContactLogoutRequest: sendContactLogoutRequest)
                    os_log("Sending contact failed. Saved to retry later.", log: OSLog.sendContactLogout, type: .info)
                }, logicError: { error in
                    NotificationCenter.default.post(name: .sendContactLogoutLogicError, object: error)
                    os_log("Sending contact logout failed. Will not retry.", log: OSLog.sendContactLogout, type: .info)
                }
            )
        } else {
            CoreDataManager.shared.contactLogoutRequest.setContactLogoutRequestToCoreData(sendContactLogoutRequest: sendContactLogoutRequest)
            os_log("Sending contact failed. Saved to retry later.", log: OSLog.sendContactLogout, type: .info)
        }
    }
}


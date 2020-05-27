//
//  CordialSwizzlerHelper.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 04.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

class CordialSwizzlerHelper {
    
    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {
        let internalCordialAPI = InternalCordialAPI()
        
        let token = internalCordialAPI.getPreparedRemoteNotificationsDeviceToken(deviceToken: deviceToken)
        
        if let pushNotificationHandler = CordialApiConfiguration.shared.pushNotificationHandler {
            pushNotificationHandler.apnsTokenReceived(token: token)
        }
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Device Token: [%{public}@]", log: OSLog.cordialPushNotification, type: .info, token)
        }
        
        self.preparePushNotificationStatus(token: token)
    }
    
    private func preparePushNotificationStatus(token: String) {
        DispatchQueue.main.async {
            let current = UNUserNotificationCenter.current()
            
            let internalCordialAPI = InternalCordialAPI()
            
            var status = String()
            
            current.getNotificationSettings(completionHandler: { (settings) in                
                if settings.authorizationStatus == .authorized {
                    status = API.PUSH_NOTIFICATION_STATUS_ALLOW
                } else {
                    status = API.PUSH_NOTIFICATION_STATUS_DISALLOW
                }
                
                internalCordialAPI.setPushNotificationStatus(status: status)
                
                self.sendPushNotificationToken(token: token, status: status)
            })
        }
    }
    
    private func sendPushNotificationToken(token: String, status: String) {
        let internalCordialAPI = InternalCordialAPI()
        
        if token != internalCordialAPI.getPushNotificationToken() {
            let primaryKey = CordialAPI().getContactPrimaryKey()
            
            let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: primaryKey, status: status, attributes: nil)
            ContactsSender.shared.upsertContacts(upsertContactRequests: [upsertContactRequest])
            
            internalCordialAPI.setPushNotificationToken(token: token)
        }
    }
}

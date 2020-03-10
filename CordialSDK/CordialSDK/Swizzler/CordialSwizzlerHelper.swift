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
        
        if token != internalCordialAPI.getPushNotificationToken() {
            let primaryKey = CordialAPI().getContactPrimaryKey()
            let status = internalCordialAPI.getPushNotificationStatus()
            
            let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: primaryKey, status: status, attributes: nil)
            ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
            
            internalCordialAPI.setPushNotificationToken(token: token)
        }
    }
    
}

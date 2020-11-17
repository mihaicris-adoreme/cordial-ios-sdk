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
    
    func didReceiveRemoteNotification(userInfo: [AnyHashable : Any]) {
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Silent push notification received. Payload: %{public}@", log: OSLog.cordialPushNotification, type: .info, userInfo)
        }
        
        let pushNotificationParser = CordialPushNotificationParser()
        
        if pushNotificationParser.isPayloadContainIAM(userInfo: userInfo) {
            InAppMessageGetter().startFetchInAppMessage(userInfo: userInfo)
        }
        
        if pushNotificationParser.isPayloadContainInboxMessage(userInfo: userInfo),
           let mcID = pushNotificationParser.getMcID(userInfo: userInfo) {
            
            CoreDataManager.shared.inboxMessagesCache.removeInboxMessageFromCoreData(mcID: mcID)
            CoreDataManager.shared.inboxMessagesContent.removeInboxMessageContentFromCoreData(mcID: mcID)
            
            if let inboxMessageDelegate = CordialApiConfiguration.shared.inboxMessageDelegate {
                inboxMessageDelegate.newInboxMessageDelivered(mcID: mcID)
            }
        }
    }
    
    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {
        let internalCordialAPI = InternalCordialAPI()
        
        let token = internalCordialAPI.getPreparedRemoteNotificationsDeviceToken(deviceToken: deviceToken)
        
        if let pushNotificationDelegate = CordialApiConfiguration.shared.pushNotificationDelegate {
            pushNotificationDelegate.apnsTokenReceived(token: token)
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
                
                CoreDataManager.shared.coreDataSender.sendCachedUpsertContactRequests()
            })
        }
    }
    
    private func sendPushNotificationToken(token: String, status: String) {
        let internalCordialAPI = InternalCordialAPI()
        
        if token != internalCordialAPI.getPushNotificationToken() {
            let primaryKey = CordialAPI().getContactPrimaryKey()
            
            let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: primaryKey, status: status, attributes: nil)
            ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
            
            internalCordialAPI.setPushNotificationToken(token: token)
        }
    }
}

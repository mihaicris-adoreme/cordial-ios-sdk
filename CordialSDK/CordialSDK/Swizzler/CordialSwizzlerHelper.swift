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
            switch CordialApiConfiguration.shared.inAppMessagesDeliveryType {
            case .silentPushes:
                InAppMessageGetter().startFetchInAppMessage(userInfo: userInfo)
            case .directDelivery:
                InAppMessagesGetter().startFetchInAppMessages(isSilentPushDeliveryEvent: true)
            }
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
        
        if internalCordialAPI.isUserLogin() || !internalCordialAPI.isUserHasBeenEverLogin() {
            self.preparePushNotificationStatus(token: token)
        }
    }
    
    private func preparePushNotificationStatus(token: String) {
        DispatchQueue.main.async {
            let current = UNUserNotificationCenter.current()
            
            var status = String()
            
            current.getNotificationSettings(completionHandler: { (settings) in                
                if settings.authorizationStatus == .authorized {
                    status = API.PUSH_NOTIFICATION_STATUS_ALLOW
                } else {
                    status = API.PUSH_NOTIFICATION_STATUS_DISALLOW
                }
                
                InternalCordialAPI().setPushNotificationStatus(status: status)
                
                self.sendPushNotificationToken(token: token, status: status)
            })
        }
    }
    
    private func sendPushNotificationToken(token: String, status: String) {
        let internalCordialAPI = InternalCordialAPI()
        
        if token != internalCordialAPI.getPushNotificationToken() {
            
            internalCordialAPI.setPushNotificationToken(token: token)
            
            let primaryKey = CordialAPI().getContactPrimaryKey()
            
            let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: primaryKey, status: status, attributes: nil)
            ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
        }
    }
        
    func sentEventDeepLinlkOpen() {
        let eventName = API.EVENT_NAME_DEEP_LINK_OPEN
        let mcID = CordialAPI().getCurrentMcID()
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
        InternalCordialAPI().sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
    }

}

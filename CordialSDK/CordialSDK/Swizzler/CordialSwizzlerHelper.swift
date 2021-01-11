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
        
        if CordialPushNotificationParser().isPayloadContainIAM(userInfo: userInfo) {
            InAppMessageGetter().startFetchInAppMessage(userInfo: userInfo)
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
    
    func convertEmailLinkToDeepLink(url: URL, onSuccess: @escaping (_ response: URL) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                onFailure("Fetching inbox messages failed. Error: [\(error.localizedDescription)]")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               let responseURL = httpResponse.url{
                
                switch httpResponse.statusCode {
                case 200:
                    onSuccess(responseURL)
                default:
                    let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    
                    onFailure("Fetching inbox messages failed. \(message)")
                }
            } else {
                onFailure("Fetching inbox messages failed. Error: [Payload is absent]")
            }
        }.resume()
    }
    
    func sentEventDeepLinlkOpen() {
        let eventName = API.EVENT_NAME_DEEP_LINK_OPEN
        let mcID = CordialAPI().getCurrentMcID()
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
        InternalCordialAPI().sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
    }

}

//
//  CordialPushNotificationHelper.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

class CordialPushNotificationHelper {
    
    let cordialAPI = CordialAPI()
    let internalCordialAPI = InternalCordialAPI()
    
    let pushNotificationParser = CordialPushNotificationParser()
    
    func pushNotificationHasBeenTapped(userInfo: [AnyHashable : Any]) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Push notification app open via tap. Payload: %{public}@", log: OSLog.cordialPushNotification, type: .info, userInfo)
        }
        
        if let mcID = self.pushNotificationParser.getMcID(userInfo: userInfo) {
            self.internalCordialAPI.setCurrentMcID(mcID: mcID)
            
            if CoreDataManager.shared.inAppMessagesShown.isInAppMessageHasBeenShown(mcID: mcID) {
                InAppMessageProcess.shared.deleteInAppMessageFromCoreDataByMcID(mcID: mcID)
            }
            
            if CordialPushNotificationParser().isPayloadContainIAM(userInfo: userInfo) {
                if let inAppMessageParams = CoreDataManager.shared.inAppMessagesParam.fetchInAppMessageParamsByMcID(mcID: mcID), inAppMessageParams.inactiveSessionDisplay == InAppMessageInactiveSessionDisplayType.hideInAppMessage {
                    DispatchQueue.main.async {
                        if !(UIApplication.shared.applicationState == .active) {
                            InAppMessageProcess.shared.deleteInAppMessageFromCoreDataByMcID(mcID: mcID)
                            
                            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                                os_log("IAM with mcID [%{public}@] has been removed.", log: OSLog.cordialInAppMessage, type: .info, mcID)
                            }
                        }
                    }
                }
            }
        }
        
        let mcID = self.cordialAPI.getCurrentMcID()
        let sendCustomEventRequest = SendCustomEventRequest(eventName: API.EVENT_NAME_PUSH_NOTIFICATION_TAP, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
        self.internalCordialAPI.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        if let deepLinkURL = self.pushNotificationParser.getDeepLinkURL(userInfo: userInfo), let cordialDeepLinksHandler = CordialApiConfiguration.shared.cordialDeepLinksHandler {
    
            InAppMessageProcess.shared.isPresentedInAppMessage = false
            
            let sendCustomEventRequest = SendCustomEventRequest(eventName: API.EVENT_NAME_DEEP_LINK_OPEN, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
            self.internalCordialAPI.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
            
            if let fallbackURL = self.pushNotificationParser.getDeepLinkFallbackURL(userInfo: userInfo) {
                if #available(iOS 13.0, *), let scene = UIApplication.shared.connectedScenes.first {
                    cordialDeepLinksHandler.openDeepLink(url: deepLinkURL, fallbackURL: fallbackURL, scene: scene)
                } else {
                    cordialDeepLinksHandler.openDeepLink(url: deepLinkURL, fallbackURL: fallbackURL)
                }
            } else {
                if #available(iOS 13.0, *), let scene = UIApplication.shared.connectedScenes.first {
                    cordialDeepLinksHandler.openDeepLink(url: deepLinkURL, fallbackURL: nil, scene: scene)
                } else {
                    cordialDeepLinksHandler.openDeepLink(url: deepLinkURL, fallbackURL: nil)
                }
            }
        }
    }
    
    func pushNotificationHasBeenForegroundDelivered(userInfo: [AnyHashable : Any]) {
        let eventName = API.EVENT_NAME_PUSH_NOTIFICATION_DELIVERED_FOREGROUND
        let mcID = self.pushNotificationParser.getMcID(userInfo: userInfo)
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
        self.internalCordialAPI.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
    }
}

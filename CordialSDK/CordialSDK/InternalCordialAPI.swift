//
//  InternalCordialAPI.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/15/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class InternalCordialAPI {
    
    // MARK: Get device identifier
    
    func getDeviceIdentifier() -> String {
        return UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID)!
    }
    
    // MARK: Set current mcID
    
    func setCurrentMcID(mcID: String) {
        UserDefaults.standard.set(mcID, forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID)
    }
    
    // MARK: JSON Web Token
    
    func setCurrentJWT(JWT: String) {
        UserDefaults.standard.set(JWT, forKey: API.USER_DEFAULTS_KEY_FOR_SDK_SECURITY_JWT)
        
        CoreDataManager.shared.coreDataSender.sendCacheFromCoreData()
    }
    
    func getCurrentJWT() -> String? {
        return UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_SDK_SECURITY_JWT)
    }
    
    // MARK: Send Any Custom Event
    
    func sendAnyCustomEvent(sendCustomEventRequest: SendCustomEventRequest) {
        CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: [sendCustomEventRequest])
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Event [eventName: %{public}@, eventID: %{public}@] added to cache", log: OSLog.cordialSendCustomEvents, type: .info, sendCustomEventRequest.eventName, sendCustomEventRequest.requestID)
        }
        
        if CoreDataManager.shared.customEventRequests.getQtyCachedCustomEventRequests() >= CordialApiConfiguration.shared.qtyCachedEventsBox {
            CoreDataManager.shared.coreDataSender.sendCachedCustomEventRequests()
        }
    }
    
    // MARK: Send Custom Event
    
    func sendCustomEvent(sendCustomEventRequest: SendCustomEventRequest) {
        let customEventsSender = CustomEventsSender()
        
        if customEventsSender.isEventNameHaveSystemPrefix(sendCustomEventRequest: sendCustomEventRequest) {
            let responseError = ResponseError(message: "Event name has system prefix", statusCode: nil, responseBody: nil, systemError: nil)
            customEventsSender.logicErrorHandler(sendCustomEventRequests: [sendCustomEventRequest], error: responseError)
        } else {
            self.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        }
    }
    
    // MARK: Get active view controller
    
    func getActiveViewController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            return topController
        }
        
        return nil
    }

    // MARK: Send first launch custom event
    
    func sendFirstLaunchCustomEvent() {
        let firstLaunch = CordialFirstLaunch(userDefaults: .standard, key: API.USER_DEFAULTS_KEY_FOR_FIRST_LAUNCH)
        if firstLaunch.isFirstLaunch {
            let eventName = API.EVENT_NAME_FIRST_LAUNCH
            let mcID = CordialAPI().getCurrentMcID()
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: nil)
            self.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        }
    }
    
    // MARK: Prepare device identifier
    
    func prepareDeviceIdentifier() {
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            UserDefaults.standard.set(deviceID, forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID)
        } else {
            UserDefaults.standard.set(UUID().uuidString, forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID)
        }
    }
    
    // MARK: Open deep link
    
    func openDeepLink(url: URL) {
        if let scheme = url.scheme, scheme.contains("http") {
            let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
            userActivity.webpageURL = url
            let _ = UIApplication.shared.delegate?.application?(UIApplication.shared, continue: userActivity, restorationHandler: { _ in })
        } else {
            UIApplication.shared.open(url, options:[:], completionHandler: nil)
        }
    }
    
    // MARK: Get push notification authorization status
    
    func getPushNotificationStatus() -> String {
        return UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) ?? API.PUSH_NOTIFICATION_STATUS_DISALLOW
    }
     
    // MARK: Set push notification authorization status
    
    func setPushNotificationStatus(status: String) {
        UserDefaults.standard.set(status, forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS)
    }
    
    // MARK: Get push notification token
    
    func getPushNotificationToken() -> String? {
        return UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN)
    }
    
    // MARK: Set push notification token
    
    func setPushNotificationToken(token: String) {
        UserDefaults.standard.set(token, forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN)
    }
}

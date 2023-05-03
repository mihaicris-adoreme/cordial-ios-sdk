//
//  InternalCordialAPI.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/15/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit
import os.log

class InternalCordialAPI {
    
    // MARK: Checking app for use scenes
    
    func isAppUseScenes() -> Bool {
        let delegateClass: AnyClass! = object_getClass(UIApplication.shared.delegate)
        
        var methodCount: UInt32 = 0
        let methodList = class_copyMethodList(delegateClass, &methodCount)
        
        if var methodList = methodList, methodCount > 0 {
            for _ in 0..<methodCount {
                let method = methodList.pointee
                
                let selector = method_getName(method)
                let selectorName = String(cString: sel_getName(selector))
                
                let connectingSceneSessionSelectorName = "application:configurationForConnectingSceneSession:options:"
                
                if selectorName == connectingSceneSessionSelectorName {
                    return true
                }
                
                methodList = methodList.successor()
            }
        }
        
        return false
    }
    
    // Get SDK resource bundle URL
    
    func getResourceBundleURL(forResource: String, withExtension: String) -> URL? {
        guard let resourceBundle = self.getResourceBundle() else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Error: [Could not get bundle that contains the model]", log: OSLog.cordialError, type: .error)
            }
            
            return nil
        }
        
        guard let resourceBundleURL = resourceBundle.url(forResource: forResource, withExtension: withExtension) else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Error: [Could not get bundle url for file %{public}@.%{public}@]", log: OSLog.cordialError, type: .error, forResource, withExtension)
            }
            
            return nil
        }
        
        return resourceBundleURL
    }
    
    // Get SDK resource bundle
    
    private func getResourceBundle() -> Bundle? {
        let frameworkIdentifier = "io.cordial.sdk"
        let frameworkName = "CordialSDK"
        
        if let bundle = Bundle(identifier: frameworkIdentifier) {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Using resource bundle by framework identifier", log: OSLog.cordialInfo, type: .info)
            }
            
            return bundle
        }
        
        guard let resourceBundleURL = Bundle(for: type(of: self)).url(forResource: frameworkName, withExtension: "bundle") else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Using resource bundle found in SPM way", log: OSLog.cordialInfo, type: .info)
            }
            
            return Bundle.resourceBundle
        }
        
        guard let resourceBundle = Bundle(url: resourceBundleURL) else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("ResourceBundle Error: [resourceBundle is nil] resourceBundleURL: [%{public}@] frameworkName: [%{public}@]", log: OSLog.cordialError, type: .error, resourceBundleURL.absoluteString, frameworkName)
            }
            
            return nil
        }
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Using resource bundle of self object", log: OSLog.cordialInfo, type: .info)
        }
        
        return resourceBundle
    }
    
    // Get expected URLSession data type
    
    func getExpectedCordialURLSessionDataType(taskName: String) -> CordialURLSessionDataType {
        switch taskName {
        case API.DOWNLOAD_TASK_NAME_SDK_SECURITY_GET_JWT:
            return .string
        case API.DOWNLOAD_TASK_NAME_CONTACT_TIMESTAMPS:
            return .string
        case API.DOWNLOAD_TASK_NAME_CONTACT_TIMESTAMP:
            return .string
        case API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGES:
            return .string
        case API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE:
            return .string
        case API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE_CONTENT:
            return .string
        case API.DOWNLOAD_TASK_NAME_SEND_CUSTOM_EVENTS:
            return .string
        case API.DOWNLOAD_TASK_NAME_UPSERT_CONTACTS:
            return .string
        case API.DOWNLOAD_TASK_NAME_SEND_CONTACT_LOGOUT:
            return .string
        case API.DOWNLOAD_TASK_NAME_UPSERT_CONTACT_CART:
            return .string
        case API.DOWNLOAD_TASK_NAME_SEND_CONTACT_ORDERS:
            return .string
        case API.DOWNLOAD_TASK_NAME_INBOX_MESSAGES_READ_UNREAD_MARKS:
            return .string
        case API.DOWNLOAD_TASK_NAME_DELETE_INBOX_MESSAGE:
            return .string
        case API.DOWNLOAD_TASK_NAME_PUSH_NOTIFICATION_CAROUSEL:
            return .image
        default:
            return .none
        }
    }

    // MARK: Remove All Cached Data
    
    func removeAllCachedData() {
        CoreDataManager.shared.deleteAllCoreData()
        self.removeCurrentMcID()
    }
    
    // MARK: Set isCurrentlyUpsertingContacts
    
    func setIsCurrentlyUpsertingContacts(_ isCurrentlyUpsertingContacts: Bool) {
        CordialUserDefaults.set(isCurrentlyUpsertingContacts, forKey: API.USER_DEFAULTS_KEY_FOR_IS_CURRENTLY_UPSERTING_CONTACTS)
    }
    
    // MARK: Get isCurrentlyUpsertingContacts
    
    func isCurrentlyUpsertingContacts() -> Bool {
        if let isCurrentlyUpsertingContacts = CordialUserDefaults.bool(forKey: API.USER_DEFAULTS_KEY_FOR_IS_CURRENTLY_UPSERTING_CONTACTS) {
            return isCurrentlyUpsertingContacts
        }
        
        return false
    }
        
    // MARK: Get device identifier
    
    func getDeviceIdentifier() -> String {
        if CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID) == nil {
            if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
                CordialUserDefaults.set(deviceID, forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID)
            } else {
                CordialUserDefaults.set(UUID().uuidString, forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID)
            }
        }
        
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID)!
    }
    
    // MARK: Get prepared remote notifications device token
    
    func getPreparedRemoteNotificationsDeviceToken(deviceToken: Data) -> String {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        
        return tokenParts.joined()
    }
    
    // MARK: Get contact key
    
    func getContactKey() -> String? {
        let cordialAPI = CordialAPI()
        
        var key: String?
        if let primaryKey = cordialAPI.getContactPrimaryKey() {
            key = primaryKey
        } else if let token = self.getPushNotificationToken() {
            let channelKey = cordialAPI.getChannelKey()
            key = "\(channelKey):\(token)"
        }
        
        return key
    }
    
    // MARK: Set primary key
    
    func setContactPrimaryKey(primaryKey: String) {
        CordialUserDefaults.set(primaryKey, forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
    }
    
    // MARK: Get previous primary key
    
    func getPreviousContactPrimaryKey() -> String? {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY)
    }
    
    // MARK: Remove previous primary key
    
    func removePreviousContactPrimaryKey() {
        CordialUserDefaults.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY)
    }

    // MARK: Set previous primary key and remove current
    
    func setPreviousPrimaryKeyAndRemoveCurrent(previousPrimaryKey: String?) {
        CordialUserDefaults.set(previousPrimaryKey, forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY)
        CordialUserDefaults.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
    }
        
    // MARK: Remove current mcID
    
    func removeCurrentMcID() {
        CordialUserDefaults.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID)
        CordialUserDefaults.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID_TAP_TIME)
    }
    
    // MARK: Get mc tap time
    
    func getCurrentMcTapTime() -> String? {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID_TAP_TIME)
    }
    
    // MARK: Move back to previous mcID
    
    func moveBackToPreviousMcID() {
        if let mcID = CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PUSH_NOTIFICATION_MCID) {
            CordialUserDefaults.set(mcID, forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID)
        }
        
        if let mcTapTime = CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PUSH_NOTIFICATION_MCID_TAP_TIME) {
            CordialUserDefaults.set(mcTapTime, forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID_TAP_TIME)
        }
    }
    
    // MARK: Save previous mcID
    
    func savePreviousMcID() {
        if let mcID = CordialAPI().getCurrentMcID() {
            CordialUserDefaults.set(mcID, forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PUSH_NOTIFICATION_MCID)
        }
        
        if let mcTapTime = self.getCurrentMcTapTime() {
            CordialUserDefaults.set(mcTapTime, forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PUSH_NOTIFICATION_MCID_TAP_TIME)
        }
    }
    
    // MARK: Set JSON Web Token
    
    func setCurrentJWT(JWT: String) {
        CordialUserDefaults.set(JWT, forKey: API.USER_DEFAULTS_KEY_FOR_SDK_SECURITY_JWT)
        
        CoreDataManager.shared.coreDataSender.sendCacheFromCoreData()
    }
    
    // MARK: Get JSON Web Token
    
    func getCurrentJWT() -> String? {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_SDK_SECURITY_JWT)
    }
    
    // MARK: Is user login
    
    func isUserLogin() -> Bool {
        if let isUserLogin = CordialUserDefaults.bool(forKey: API.USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN) {
            return isUserLogin
        }
        
        return false
    }
    
    // MARK: Is user has been ever login
    
    func hasUserBeenLoggedIn() -> Bool {
        if CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN) == nil {
            return false
        }
        
        return true
    }
    
    // MARK: Send Any Custom Event
    
    func sendAnyCustomEvent(sendCustomEventRequest: SendCustomEventRequest) {
        CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: [sendCustomEventRequest])
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            if CordialApiConfiguration.shared.eventsBulkSize != 1 {
                os_log("Event [eventName: %{public}@, eventID: %{public}@] added to bulk", log: OSLog.cordialSendCustomEvents, type: .info, sendCustomEventRequest.eventName, sendCustomEventRequest.requestID)
            }
        }
        
        ThrottlerManager.shared.sendCustomEventRequest.throttle {
            guard let qtyCachedCustomEventRequests = CoreDataManager.shared.customEventRequests.getQtyCachedCustomEventRequests() else { return }
            
            if qtyCachedCustomEventRequests >= CordialApiConfiguration.shared.eventsBulkSize {
                CoreDataManager.shared.coreDataSender.sendCachedCustomEventRequests(reason: "Bulk size is full")
            }
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
    
    // MARK: Get top view controller
    
    func getTopViewController(of viewController: UIViewController?) -> UIViewController? {
        switch viewController {
        case is UIAlertController:
            let alertController = viewController as! UIAlertController
            return self.getTopViewController(of: alertController.presentingViewController)
        case is UIActivityViewController:
            let activityViewController = viewController as! UIActivityViewController
            return self.getTopViewController(of: activityViewController.presentingViewController)
        default:
            return viewController
        }
    }

    // MARK: Send first launch custom event
    
    func sendFirstLaunchCustomEvent() {
        let firstLaunch = CordialFirstLaunch(userDefaults: .standard, key: API.USER_DEFAULTS_KEY_FOR_FIRST_LAUNCH)
        if firstLaunch.isFirstLaunch {
            let eventName = API.EVENT_NAME_FIRST_LAUNCH
            let mcID = CordialAPI().getCurrentMcID()
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
            self.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        }
    }
    
    // MARK: Open deep link
    
    func openDeepLink(url: URL) {
        // UIKit
        DispatchQueue.main.async {
            if let scheme = url.scheme, scheme.contains("http") {
                let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                userActivity.webpageURL = url
                
                if #available(iOS 13.0, *), self.isAppUseScenes(),
                    let scene = UIApplication.shared.connectedScenes.first {
                    
                    CordialSwizzler.shared.scene(scene, continue: userActivity)
                } else {
                    let _ = CordialSwizzler.shared.application(UIApplication.shared, continue: userActivity, restorationHandler: { _ in })
                }
            } else {
                if #available(iOS 13.0, *), self.isAppUseScenes(),
                   let scene = UIApplication.shared.connectedScenes.first {
                    
                    CordialSwizzlerHelper().processSceneOpenURLContexts(url: url, scene: scene)
                } else {
                    let _ = CordialSwizzlerHelper().processAppOpenOptions(url: url)
                }
            }
        }
        
        // SwiftUI
        if #available(iOS 13.0, *) {
            DispatchQueue.main.async {
                let cordialDeepLink = self.getCordialDeepLink(url: url)
                
                CordialSwiftUIDeepLinksPublisher.shared.publishDeepLink(deepLink: cordialDeepLink, fallbackURL: nil, completionHandler: { deepLinkActionType in
                    
                    self.deepLinkAction(deepLinkActionType: deepLinkActionType)
                })
            }
        }
    }
    
    func processPushNotificationDeepLink(url: URL, userInfo: [AnyHashable : Any]) {
        InAppMessageProcess.shared.isPresentedInAppMessage = false
        
        if let host = url.host,
           CordialApiConfiguration.shared.vanityDomains.contains(host) {
            
            CordialVanityDeepLink().open(url: url)
        } else {
            self.sentEventDeepLinkOpen(url: url)
            
            let pushNotificationParser = PushNotificationParser()
            
            let vanityDeepLinkURL = pushNotificationParser.getVanityDeepLinkURL(userInfo: userInfo)
            let cordialDeepLink = CordialDeepLink(url: url, vanityURL: vanityDeepLinkURL)
            
            let fallbackURL = pushNotificationParser.getDeepLinkFallbackURL(userInfo: userInfo)
            
            // UIKit
            if let cordialDeepLinksDelegate = CordialApiConfiguration.shared.cordialDeepLinksDelegate {
                DispatchQueue.main.async {
                    if #available(iOS 13.0, *), self.isAppUseScenes(),
                        let scene = UIApplication.shared.connectedScenes.first {
                        
                        cordialDeepLinksDelegate.openDeepLink(deepLink: cordialDeepLink, fallbackURL: fallbackURL, scene: scene, completionHandler: { deepLinkActionType in
                            
                            self.deepLinkAction(deepLinkActionType: deepLinkActionType)
                        })
                    } else {
                        cordialDeepLinksDelegate.openDeepLink(deepLink: cordialDeepLink, fallbackURL: fallbackURL, completionHandler: { deepLinkActionType in
                            
                            self.deepLinkAction(deepLinkActionType: deepLinkActionType)
                        })
                    }
                }
            }
            
            // SwiftUI
            if #available(iOS 13.0, *) {
                DispatchQueue.main.async {
                    CordialSwiftUIDeepLinksPublisher.shared.publishDeepLink(deepLink: cordialDeepLink, fallbackURL: fallbackURL, completionHandler: { deepLinkActionType in
                        
                        self.deepLinkAction(deepLinkActionType: deepLinkActionType)
                    })
                }
            }
        }
    }
    
    // MARK: Deep link action
    
    func deepLinkAction(deepLinkActionType: CordialDeepLinkActionType) {
        switch deepLinkActionType {
        case .OPEN_IN_BROWSER:
            if !NotificationManager.shared.originDeepLink.isEmpty,
               let originDeepLinkURL = URL(string: NotificationManager.shared.originDeepLink) {
                
                self.moveBackToPreviousMcID()
                
                NotificationManager.shared.originDeepLink = String()
                
                DispatchQueue.main.async {
                    if let url = self.getSkipTrackingDeepLinkURL(url: originDeepLinkURL) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        case .NO_ACTION:
            break
        }
    }
    
    func getCordialDeepLink(url: URL) -> CordialDeepLink {
        var cordialDeepLink = CordialDeepLink(url: url, vanityURL: nil)
        
        if !NotificationManager.shared.originDeepLink.isEmpty,
           let originDeepLinkURL = URL(string: NotificationManager.shared.originDeepLink),
           url.absoluteString != NotificationManager.shared.originDeepLink {
            
            let vanityDeepLinkURL = self.getSkipTrackingDeepLinkURL(url: originDeepLinkURL)
            
            cordialDeepLink = CordialDeepLink(url: url, vanityURL: vanityDeepLinkURL)
        }
        
        return cordialDeepLink
    }
    
    private func getSkipTrackingDeepLinkURL(url: URL) -> URL? {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        let keyForSkipTracking = [URLQueryItem(name: "cookie-only", value: "1")]
        if var queryItems = urlComponents.queryItems {
            queryItems += keyForSkipTracking
            urlComponents.queryItems = queryItems
        } else {
            urlComponents.queryItems = keyForSkipTracking
        }
        
        return urlComponents.url
    }
    
    // MARK: Sent event deep link open
    
    func sentEventDeepLinkOpen(url: URL) {
        let eventName = API.EVENT_NAME_DEEP_LINK_OPEN
        let mcID = CordialAPI().getCurrentMcID()
        
        var properties: Dictionary<String, Any> = ["deepLinkUrl": url]
        if let systemEventsProperties = CordialApiConfiguration.shared.systemEventsProperties {
            properties.merge(systemEventsProperties) { (current, new) in current }
        }
        
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: properties)
        self.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
    }
    
    // MARK: Get push notification status
    
    func getPushNotificationStatus() -> String {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) ?? API.PUSH_NOTIFICATION_STATUS_DISALLOW
    }
    
    // MARK: Get push notification authorization status
    
    private func getPushNotificationAuthorizationStatus() -> UNAuthorizationStatus {
        guard let rawValue = CordialUserDefaults.integer(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_AUTHORIZATION_STATUS),
                let authorizationStatus = UNAuthorizationStatus(rawValue: rawValue) else {
            
            return .notDetermined
        }
        
        return authorizationStatus
    }
     
    // MARK: Set push notification status
    
    func setPushNotificationStatus(status: String, authorizationStatus: UNAuthorizationStatus) {
        CordialUserDefaults.set(status, forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS)
        
        self.setPushNotificationAuthorizationStatus(authorizationStatus: authorizationStatus)
    }
    
    private func setPushNotificationAuthorizationStatus(authorizationStatus: UNAuthorizationStatus) {
        let prevAuthorizationStatus = self.getPushNotificationAuthorizationStatus()
        
        if authorizationStatus != prevAuthorizationStatus {
            let mcID = CordialAPI().getCurrentMcID()
            
            switch authorizationStatus {
            case .denied:
                let systemEventsProperties = self.getAuthorizationStatusSystemEventsProperties(authorizationStatus: prevAuthorizationStatus)
                let sendCustomEventRequest = SendCustomEventRequest(eventName: API.EVENT_NAME_PUSH_NOTIFICATIONS_MANUAL_OPTOUT, mcID: mcID, properties: systemEventsProperties)
                self.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
                
                CordialUserDefaults.set(authorizationStatus.rawValue, forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_AUTHORIZATION_STATUS)
            case .authorized, .provisional:
                let systemEventsProperties = self.getAuthorizationStatusSystemEventsProperties(authorizationStatus: authorizationStatus)
                let sendCustomEventRequest = SendCustomEventRequest(eventName: API.EVENT_NAME_PUSH_NOTIFICATIONS_MANUAL_OPTIN, mcID: mcID, properties: systemEventsProperties)
                self.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
                
                CordialUserDefaults.set(authorizationStatus.rawValue, forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_AUTHORIZATION_STATUS)
            default: break
            }
        }
    }
    
    // MARK: Get authorization status systemEventsProperties
    
    func getAuthorizationStatusSystemEventsProperties(authorizationStatus: UNAuthorizationStatus) -> Dictionary<String, Any> {
        var authorizationStatusName = "notDetermined"
        
        switch authorizationStatus {
        case .denied:
            authorizationStatusName = "denied"
        case .authorized:
            authorizationStatusName = "authorized"
        case .provisional:
            authorizationStatusName = "provisional"
        default: break
        }
        
        var properties: Dictionary<String, Any> = ["authorizationStatus": authorizationStatusName]
        
        if let systemEventsProperties = CordialApiConfiguration.shared.systemEventsProperties {
            properties.merge(systemEventsProperties) { (current, new) in current }
        }
        
        return properties
    }
    
    // MARK: Get push notification token
    
    func getPushNotificationToken() -> String? {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN)
    }
    
    // MARK: Set push notification token
    
    func setPushNotificationToken(token: String) {
        CordialUserDefaults.set(token, forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN)
    }
    
    // MARK: Set push notification categories
    
    func setPushNotificationCategories(pushNotificationCategories: [PushNotificationCategory], key: String = API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CATEGORIES) {
        if key == API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CATEGORIES {
            var enabledKeys: [String] = []
            
            pushNotificationCategories.forEach { settings in
                if settings.initState {
                    enabledKeys.append(settings.key)
                }
            }
            
            let attributes = ArrayValue(enabledKeys)
            CordialAPI().upsertContact(attributes: [API.UPSERT_CONTACT_ATTRIBUTES_NAME_PUSH_NOTIFICATION_CATEGORIES: attributes])
        }
        
        let pushNotificationCategoriesData = try? NSKeyedArchiver.archivedData(withRootObject: pushNotificationCategories, requiringSecureCoding: false)
        CordialUserDefaults.set(pushNotificationCategoriesData, forKey: key)
    }
    
    // MARK: Get push notification categories
    
    func getPushNotificationCategories(key: String = API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CATEGORIES) -> [PushNotificationCategory] {
        guard let pushNotificationCategoriesData = CordialUserDefaults.object(forKey: key) as? Data,
              let pushNotificationCategoriesUnarchive = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(pushNotificationCategoriesData),
              let pushNotificationCategories = pushNotificationCategoriesUnarchive as? [PushNotificationCategory] else {
            
            return [PushNotificationCategory]()
        }
        
        for pushNotificationCategory in pushNotificationCategories {
            if pushNotificationCategory.isError {
                return [PushNotificationCategory]()
            }
        }
        
        return pushNotificationCategories
    }
    
    // MARK: Is new push notification categories
    
    func isNewPushNotificationCategories(pushNotificationCategories: [PushNotificationCategory]) -> Bool {
        let pushNotificationCategoriesOrigin = self.getPushNotificationCategories(key: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CATEGORIES_ORIGIN)
        
        func getSettingsJSON(_ pushNotificationCategories: [PushNotificationCategory]) -> String {
            var rootContainer = [String]()
            
            for pushNotificationCategory in pushNotificationCategories {
                let container = [
                    "\"key\": \"\(pushNotificationCategory.key)\"",
                    "\"name\": \"\(pushNotificationCategory.name)\"",
                    "\"initState\": \(pushNotificationCategory.initState)"
                ]
                
                let containerString = "{ \(container.joined(separator: ", ")) }"
                
                rootContainer.append(containerString)
            }
            
            return "[ \(rootContainer.joined(separator: ", ")) ]"
        }
        
        let pushNotificationCategoriesJSON = getSettingsJSON(pushNotificationCategories)
        let pushNotificationCategoriesOriginJSON = getSettingsJSON(pushNotificationCategoriesOrigin)
        
        if pushNotificationCategoriesJSON != pushNotificationCategoriesOriginJSON {
            return true
        }
        
        return false
    }
    
    // MARK: Get the latest sentAt IAM
    
    func getTheLatestSentAtInAppMessageDate() -> String? {        
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_THE_LATEST_SENT_AT_IN_APP_MESSAGE_DATE)
    }
    
    // MARK: Set the latest sentAt IAM
    
    func setTheLatestSentAtInAppMessageDate(sentAtTimestamp: String) {
        CordialUserDefaults.set(sentAtTimestamp, forKey: API.USER_DEFAULTS_KEY_FOR_THE_LATEST_SENT_AT_IN_APP_MESSAGE_DATE)
    }
    
    func removeTheLatestSentAtInAppMessageDate() {
        CordialUserDefaults.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_THE_LATEST_SENT_AT_IN_APP_MESSAGE_DATE)
    }
    
    func removeContactTimestampFromCoreDataAndTheLatestSentAtInAppMessageDate() {
        CoreDataManager.shared.contactTimestampsURL.removeContactTimestampFromCoreData()
        self.removeTheLatestSentAtInAppMessageDate()
    }

}

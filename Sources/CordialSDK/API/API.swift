//
//  API.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

struct API {
    
    static let USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN = "USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN"
    static let USER_DEFAULTS_KEY_FOR_PRIMARY_KEY = "USER_DEFAULTS_KEY_FOR_PRIMARY_KEY"
    static let USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY = "USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY"
    static let USER_DEFAULTS_KEY_FOR_FIRST_LAUNCH = "USER_DEFAULTS_KEY_FOR_FIRST_LAUNCH"
    static let USER_DEFAULTS_KEY_FOR_DEVICE_ID = "USER_DEFAULTS_KEY_FOR_DEVICE_ID"
    static let USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN = "USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN"
    static let USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID = "USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID"
    static let USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID_TAP_TIME = "USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID_TAP_TIME"
    static let USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CATEGORIES = "USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CATEGORIES"
    static let USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CATEGORIES_ORIGIN = "USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CATEGORIES_ORIGIN"
    static let USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_IMAGES = "USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_IMAGES"
    static let USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_DEEP_LINKS = "USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_DEEP_LINKS"
    static let USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_DEEP_LINK_ID = "USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_DEEP_LINK_ID"
    static let USER_DEFAULTS_KEY_FOR_PREVIOUS_PUSH_NOTIFICATION_MCID = "USER_DEFAULTS_KEY_FOR_PREVIOUS_PUSH_NOTIFICATION_MCID"
    static let USER_DEFAULTS_KEY_FOR_PREVIOUS_PUSH_NOTIFICATION_MCID_TAP_TIME = "USER_DEFAULTS_KEY_FOR_PREVIOUS_PUSH_NOTIFICATION_MCID_TAP_TIME"
    static let USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS = "USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS"
    static let USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_AUTHORIZATION_STATUS = "USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_AUTHORIZATION_STATUS"
    static let USER_DEFAULTS_KEY_FOR_CURRENT_LOCATION_LATITUDE = "USER_DEFAULTS_KEY_FOR_CURRENT_LOCATION_LATITUDE"
    static let USER_DEFAULTS_KEY_FOR_CURRENT_LOCATION_LONGITUDE = "USER_DEFAULTS_KEY_FOR_CURRENT_LOCATION_LONGITUDE"
    static let USER_DEFAULTS_KEY_FOR_SDK_SECURITY_JWT = "USER_DEFAULTS_KEY_FOR_SDK_SECURITY_JWT"
    static let USER_DEFAULTS_KEY_FOR_UPSERT_CONTACTS_LAST_UPDATE_DATE = "USER_DEFAULTS_KEY_FOR_UPSERT_CONTACTS_LAST_UPDATE_DATE"
    static let USER_DEFAULTS_KEY_FOR_IS_CURRENTLY_UPSERTING_CONTACTS = "USER_DEFAULTS_KEY_FOR_IS_CURRENTLY_UPSERTING_CONTACTS"
    static let USER_DEFAULTS_KEY_FOR_THE_LATEST_SENT_AT_IN_APP_MESSAGE_DATE = "USER_DEFAULTS_KEY_FOR_THE_LATEST_SENT_AT_IN_APP_MESSAGE_DATE"
    
    static let DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE = "DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE"
    static let DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE_CONTENT = "DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE_CONTENT"
    static let DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGES = "DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGES"
    static let DOWNLOAD_TASK_NAME_SDK_SECURITY_GET_JWT = "DOWNLOAD_TASK_NAME_SDK_SECURITY_GET_JWT"
    static let DOWNLOAD_TASK_NAME_SEND_CUSTOM_EVENTS = "DOWNLOAD_TASK_NAME_SEND_CUSTOM_EVENTS"
    static let DOWNLOAD_TASK_NAME_UPSERT_CONTACTS = "DOWNLOAD_TASK_NAME_UPSERT_CONTACTS"
    static let DOWNLOAD_TASK_NAME_SEND_CONTACT_LOGOUT = "DOWNLOAD_TASK_NAME_SEND_CONTACT_LOGOUT"
    static let DOWNLOAD_TASK_NAME_UPSERT_CONTACT_CART = "DOWNLOAD_TASK_NAME_UPSERT_CONTACT_CART"
    static let DOWNLOAD_TASK_NAME_SEND_CONTACT_ORDERS = "DOWNLOAD_TASK_NAME_SEND_CONTACT_ORDERS"
    static let DOWNLOAD_TASK_NAME_INBOX_MESSAGES_READ_UNREAD_MARKS = "DOWNLOAD_TASK_NAME_INBOX_MESSAGES_READ_UNREAD_MARKS"
    static let DOWNLOAD_TASK_NAME_DELETE_INBOX_MESSAGE = "DOWNLOAD_TASK_NAME_DELETE_INBOX_MESSAGE"
    static let DOWNLOAD_TASK_NAME_CONTACT_TIMESTAMPS = "DOWNLOAD_TASK_NAME_CONTACT_TIMESTAMPS"
    static let DOWNLOAD_TASK_NAME_CONTACT_TIMESTAMP = "DOWNLOAD_TASK_NAME_CONTACT_TIMESTAMP"
    static let DOWNLOAD_TASK_NAME_PUSH_NOTIFICATION_CAROUSEL = "DOWNLOAD_TASK_NAME_PUSH_NOTIFICATION_CAROUSEL"
    
    static let SYSTEM_EVENT_PREFIX = "crdl_"
    
    static let EVENT_NAME_FIRST_LAUNCH = "\(API.SYSTEM_EVENT_PREFIX)app_install"
    static let EVENT_NAME_APP_MOVED_TO_BACKGROUND = "\(API.SYSTEM_EVENT_PREFIX)app_close"
    static let EVENT_NAME_APP_MOVED_FROM_BACKGROUND = "\(API.SYSTEM_EVENT_PREFIX)app_open"
    static let EVENT_NAME_PUSH_NOTIFICATION_DELIVERED_FOREGROUND = "\(API.SYSTEM_EVENT_PREFIX)notification_delivered_in_foreground"
    static let EVENT_NAME_PUSH_NOTIFICATION_TAP = "\(API.SYSTEM_EVENT_PREFIX)notification_tap"
    static let EVENT_NAME_PUSH_NOTIFICATIONS_MANUAL_OPTIN = "device_notifications_manual_optin" // TMP - need to add `crdl_`
    static let EVENT_NAME_PUSH_NOTIFICATIONS_MANUAL_OPTOUT = "device_notifications_manual_optout" // TMP - need to add `crdl_`
    static let EVENT_NAME_DEEP_LINK_OPEN = "\(API.SYSTEM_EVENT_PREFIX)deep_link_open"
    static let EVENT_NAME_IN_APP_MESSAGE_WAS_SHOWN = "\(API.SYSTEM_EVENT_PREFIX)in_app_message_shown"
    static let EVENT_NAME_AUTO_REMOVE_IN_APP_MESSAGE = "\(API.SYSTEM_EVENT_PREFIX)in_app_message_auto_dismiss"
    static let EVENT_NAME_MANUAL_REMOVE_IN_APP_MESSAGE = "\(API.SYSTEM_EVENT_PREFIX)in_app_message_manual_dismiss"
    static let EVENT_NAME_INBOX_MESSAGE_READ = "\(API.SYSTEM_EVENT_PREFIX)inbox_read"
    
    static let UPSERT_CONTACT_ATTRIBUTES_NAME_PUSH_NOTIFICATION_CATEGORIES = "\(API.SYSTEM_EVENT_PREFIX)notification_categories"
    
    static let BACKGROUND_URL_SESSION_IDENTIFIER = "CordialSDKBackgroundURLSession"
    
    static let SECURITY_APPLICATION_GROUP_IDENTIFIER = "group.cordial.sdk"
    
    static let IAM_WEB_VIEW_BASE_URL = "IAM_WEB_VIEW_BASE_URL"
    
    static let PUSH_NOTIFICATION_STATUS_ALLOW = "opt-in"
    static let PUSH_NOTIFICATION_STATUS_DISALLOW = "opt-out"
    
    static func getDictionaryJSON(_ dictionary: Dictionary<String, Any>?) -> String {
        guard let json = dictionary as NSDictionary?,
              let jsonString = JSONStructure().box(json)?.walk() else {
                  
            return "{ }"
        }
        
        return jsonString
    }
    
    static func getArrayJSON(_ array: [Any]?) -> String {
        guard let json = array as NSArray?,
              let jsonString = JSONStructure().box(json)?.walk() else {
                  
            return "[ ]"
        }
        
        return jsonString
    }
    
    static func isValidExpirationDate(date: Date) -> Bool {
        if Int(date.timeIntervalSinceNow).signum() == 1 {
            return true
        }
        
        return false
    }
        
    static func sizeFormatter(data: Data, formatter: ByteCountFormatter.Units) -> String {
        let byteCountFormatter = ByteCountFormatter()
        
        byteCountFormatter.allowedUnits = formatter
        byteCountFormatter.countStyle = .file
        
        return byteCountFormatter.string(fromByteCount: Int64(data.count))
    }
}

extension UIColor {
    func inverseColor() -> UIColor {
        var alpha: CGFloat = 1.0

        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue, alpha: alpha)
        }

        var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: 1.0 - hue, saturation: 1.0 - saturation, brightness: 1.0 - brightness, alpha: alpha)
        }

        var white: CGFloat = 0.0
        if self.getWhite(&white, alpha: &alpha) {
            return UIColor(white: 1.0 - white, alpha: alpha)
        }

        return self
    }
}

extension String {
    func replacingFirstOccurrence(of targetString: String, with replaceString: String) -> String {
        if let range = self.range(of: targetString) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
}

extension Date {
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}

extension Sequence {
    var count: Int { return reduce(0) { acc, row in acc + 1 } }
}

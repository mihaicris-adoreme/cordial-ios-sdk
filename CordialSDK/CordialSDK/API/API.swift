//
//  API.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

struct API {
    
    static let USER_DEFAULTS_KEY_FOR_PRIMARY_KEY = "USER_DEFAULTS_KEY_FOR_PRIMARY_KEY"
    static let USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY = "USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY"
    static let USER_DEFAULTS_KEY_FOR_BASR_URL = "USER_DEFAULTS_KEY_FOR_BASR_URL"
    static let USER_DEFAULTS_KEY_FOR_ACCOUNT_KEY = "USER_DEFAULTS_KEY_FOR_ACCOUNT_KEY"
    static let USER_DEFAULTS_KEY_FOR_CHANNEL_KEY = "USER_DEFAULTS_KEY_FOR_CHANNEL_KEY"
    static let USER_DEFAULTS_KEY_FOR_FIRST_LAUNCH = "USER_DEFAULTS_KEY_FOR_FIRST_LAUNCH"
    static let USER_DEFAULTS_KEY_FOR_DEVICE_ID = "USER_DEFAULTS_KEY_FOR_DEVICE_ID"
    static let USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN = "USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN"
    static let USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID = "USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID"
    static let USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS = "USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS"
    static let USER_DEFAULTS_KEY_FOR_CURRENT_LOCATION_LATITUDE = "USER_DEFAULTS_KEY_FOR_CURRENT_LOCATION_LATITUDE"
    static let USER_DEFAULTS_KEY_FOR_CURRENT_LOCATION_LONGITUDE = "USER_DEFAULTS_KEY_FOR_CURRENT_LOCATION_LONGITUDE"
    static let USER_DEFAULTS_KEY_FOR_SDK_SECURITY_JWT = "USER_DEFAULTS_KEY_FOR_SDK_SECURITY_JWT"
    
    static let DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE = "DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE"
    static let DOWNLOAD_TASK_NAME_SDK_SECURITY_GET_JWT = "DOWNLOAD_TASK_NAME_SDK_SECURITY_GET_JWT"
    static let DOWNLOAD_TASK_NAME_SEND_CUSTOM_EVENTS = "DOWNLOAD_TASK_NAME_SEND_CUSTOM_EVENTS"
    static let DOWNLOAD_TASK_NAME_UPSERT_CONTACTS = "DOWNLOAD_TASK_NAME_UPSERT_CONTACTS"
    static let DOWNLOAD_TASK_NAME_SEND_CONTACT_LOGOUT = "DOWNLOAD_TASK_NAME_SEND_CONTACT_LOGOUT"
    static let DOWNLOAD_TASK_NAME_UPSERT_CONTACT_CART = "DOWNLOAD_TASK_NAME_UPSERT_CONTACT_CART"
    static let DOWNLOAD_TASK_NAME_SEND_CONTACT_ORDERS = "DOWNLOAD_TASK_NAME_SEND_CONTACT_ORDERS"
    
    static let SYSTEM_EVENT_PREFIX = "crdl_"
    
    static let EVENT_NAME_FIRST_LAUNCH = "\(API.SYSTEM_EVENT_PREFIX)app_install"
    static let EVENT_NAME_APP_MOVED_TO_BACKGROUND = "\(API.SYSTEM_EVENT_PREFIX)app_close"
    static let EVENT_NAME_APP_MOVED_FROM_BACKGROUND = "\(API.SYSTEM_EVENT_PREFIX)app_open"
    static let EVENT_NAME_PUSH_NOTIFICATION_DELIVERED_FOREGROUND = "\(API.SYSTEM_EVENT_PREFIX)notification_delivered_in_foreground"
    static let EVENT_NAME_PUSH_NOTIFICATION_TAP = "\(API.SYSTEM_EVENT_PREFIX)notification_tap"
    static let EVENT_NAME_DEEP_LINK_OPEN = "\(API.SYSTEM_EVENT_PREFIX)deep_link_open"
    static let EVENT_NAME_IN_APP_MESSAGE_WAS_SHOWN = "\(API.SYSTEM_EVENT_PREFIX)in_app_message_shown"
    static let EVENT_NAME_AUTO_REMOVE_IN_APP_MESSAGE = "\(API.SYSTEM_EVENT_PREFIX)in_app_message_auto_dismiss"
    static let EVENT_NAME_MANUAL_REMOVE_IN_APP_MESSAGE = "\(API.SYSTEM_EVENT_PREFIX)in_app_message_manual_dismiss"
    
    static let PUSH_NOTIFICATION_STATUS_ALLOW = "opt-in"
    static let PUSH_NOTIFICATION_STATUS_DISALLOW = "opt-out"
    
    static func getDictionaryJSON(stringDictionary: Dictionary<String, String>) -> String {
        var stringDictionaryContainer = [String]()
        stringDictionary.forEach { (key: String, value: String) in
            stringDictionaryContainer.append("\"\(key)\": \"\(value)\"")
        }
        
        let stringContainer = stringDictionaryContainer.joined(separator: ", ")
        
        return "{ \(stringContainer) }"
    }
    
    static func getStringArrayJSON(stringArray: [String]) -> String {
        var stringArrayContainer = [String]()
        stringArray.forEach({ image in
            stringArrayContainer.append(image)
        })
        
        let stringContainer = stringArrayContainer.joined(separator: ", ")
        
        return "[ \(stringContainer) ]"
    }
}

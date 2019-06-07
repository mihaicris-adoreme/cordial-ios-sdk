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
    
    static let FIRST_LAUNCH_EVENT_NAME = "app_install"
    static let APP_MOVED_TO_BACKGROUND = "app_close"
    static let APP_MOVED_FROM_BACKGROUND = "app_open"
    static let PUSH_NOTIFICATION_DELIVERED_FOREGROUND = "notification_delivered_in_foreground"
    static let PUSH_NOTIFICATION_APP_OPEN_VIA_TAP = "app_open_via_notification_tap"
    static let DEEP_LINKS_APP_OPEN_VIA_UNIVERSAL_LINK = "app_open_via_universal_link"
    static let DEEP_LINKS_APP_OPEN_VIA_URL_SCHEME = "app_open_via_url_scheme"
    static let PUSH_NOTIFICATION_STATUS_ALLOW = "opt-in"
    static let PUSH_NOTIFICATION_STATUS_DISALLOW = "opt-out"
    
    static func getDictionaryJSON(stringDictionary: Dictionary<String, String>) -> String {
        var stringDictionaryContainer = [String]()
        stringDictionary.forEach { (key: String, value: String) in
            stringDictionaryContainer.append("\"\(key)\": \"\(value)\"")
        }
        
        return "{ " + stringDictionaryContainer.joined(separator: ", ") + " }"
    }
    
    static func getStringArrayJSON(stringArray: [String]) -> String {
        var stringArrayContainer = [String]()
        stringArray.forEach({ image in
            stringArrayContainer.append(image)
        })
        
        return "[ " + stringArrayContainer.joined(separator: ", ") + " ]"
    }
}

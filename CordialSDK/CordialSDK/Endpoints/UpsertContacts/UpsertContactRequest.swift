//
//  UpsertContactRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/6/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

public class UpsertContactRequest: NSObject, NSCoding {
    
    let deviceID: String
    let token: String?
    let primaryKey: String?
    public var subscribeStatus: SubscribeStatus?
    let status: String
    let attributes: Dictionary<String, String>?
    
    let cordialAPI = CordialAPI()
    let internalCordialAPI = InternalCordialAPI()
    
    public enum SubscribeStatus: String {
        case subscribed = "subscribed"
        case unsubscribed = "unsubscribed"
    }
    
    enum Key: String {
        case token = "token"
        case primaryKey = "primaryKey"
        case attributes = "attributes"
    }
    
    public init(attributes: Dictionary<String, String>?) {
        self.deviceID = internalCordialAPI.getDeviceIdentifier()
        self.token = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN)
        self.primaryKey = cordialAPI.getContactPrimaryKey()
        self.status = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) ?? API.PUSH_NOTIFICATION_STATUS_DISALLOW
        self.attributes = attributes
    }
    
    internal init(token: String) {
        UserDefaults.standard.set(token, forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN)
        
        self.deviceID = internalCordialAPI.getDeviceIdentifier()
        self.token = token
        self.primaryKey = cordialAPI.getContactPrimaryKey()
        self.status = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) ?? API.PUSH_NOTIFICATION_STATUS_DISALLOW
        self.attributes = nil
    }
    
    internal init(status: String) {
        UserDefaults.standard.set(status, forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS)
        
        self.deviceID = internalCordialAPI.getDeviceIdentifier()
        self.token = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN)
        self.primaryKey = cordialAPI.getContactPrimaryKey()
        self.status = status
        self.attributes = nil
    }
    
    internal init(primaryKey: String?) {
        self.deviceID = internalCordialAPI.getDeviceIdentifier()
        self.token = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN)
        self.primaryKey = primaryKey
        self.status = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) ?? API.PUSH_NOTIFICATION_STATUS_DISALLOW
        self.attributes = nil
    }
    
    private init(token: String?, primaryKey: String?, attributes: Dictionary<String, String>?) {
        self.deviceID = internalCordialAPI.getDeviceIdentifier()
        self.token = token
        self.primaryKey = primaryKey
        self.status = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) ?? API.PUSH_NOTIFICATION_STATUS_DISALLOW
        self.attributes = attributes
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.token, forKey: Key.token.rawValue)
        aCoder.encode(self.primaryKey, forKey: Key.primaryKey.rawValue)
        aCoder.encode(self.attributes, forKey: Key.attributes.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let token = aDecoder.decodeObject(forKey: Key.token.rawValue) as! String?
        let primaryKey = aDecoder.decodeObject(forKey: Key.primaryKey.rawValue) as! String?
        let attributes = aDecoder.decodeObject(forKey: Key.attributes.rawValue) as! Dictionary<String, String>?
        
        self.init(token: token, primaryKey: primaryKey, attributes: attributes)
    }
}

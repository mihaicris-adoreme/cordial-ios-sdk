//
//  UpsertContactRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/6/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public class UpsertContactRequest: NSObject, NSCoding {
    
    let requestID: String
    let token: String?
    let primaryKey: String?
    let status: String
    let attributes: Dictionary<String, String>?
    
    let cordialAPI = CordialAPI()
    let internalCordialAPI = InternalCordialAPI()
    
    enum Key: String {
        case requestID = "requestID"
        case token = "token"
        case primaryKey = "primaryKey"
        case attributes = "attributes"
    }
    
    @objc public init(attributes: Dictionary<String, String>?) {
        self.requestID = UUID().uuidString
        self.token = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN)
        self.primaryKey = cordialAPI.getContactPrimaryKey()
        self.status = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) ?? API.PUSH_NOTIFICATION_STATUS_DISALLOW
        self.attributes = attributes
    }
    
    internal init(token: String) {
        UserDefaults.standard.set(token, forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN)
        
        self.requestID = UUID().uuidString
        self.token = token
        self.primaryKey = cordialAPI.getContactPrimaryKey()
        self.status = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) ?? API.PUSH_NOTIFICATION_STATUS_DISALLOW
        self.attributes = nil
    }
    
    internal init(status: String) {
        UserDefaults.standard.set(status, forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS)
        
        self.requestID = UUID().uuidString
        self.token = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN)
        self.primaryKey = cordialAPI.getContactPrimaryKey()
        self.status = status
        self.attributes = nil
    }
    
    internal init(primaryKey: String?) {
        self.requestID = UUID().uuidString
        self.token = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN)
        self.primaryKey = primaryKey
        self.status = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) ?? API.PUSH_NOTIFICATION_STATUS_DISALLOW
        self.attributes = nil
    }
    
    private init(requestID: String, token: String?, primaryKey: String?, attributes: Dictionary<String, String>?) {
        self.requestID = requestID
        self.token = token
        self.primaryKey = primaryKey
        self.status = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) ?? API.PUSH_NOTIFICATION_STATUS_DISALLOW
        self.attributes = attributes
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.requestID, forKey: Key.requestID.rawValue)
        aCoder.encode(self.token, forKey: Key.token.rawValue)
        aCoder.encode(self.primaryKey, forKey: Key.primaryKey.rawValue)
        aCoder.encode(self.attributes, forKey: Key.attributes.rawValue)
    }
    
    @objc public required convenience init?(coder aDecoder: NSCoder) {
        let requestID = aDecoder.decodeObject(forKey: Key.requestID.rawValue) as! String
        let token = aDecoder.decodeObject(forKey: Key.token.rawValue) as! String?
        let primaryKey = aDecoder.decodeObject(forKey: Key.primaryKey.rawValue) as! String?
        let attributes = aDecoder.decodeObject(forKey: Key.attributes.rawValue) as! Dictionary<String, String>?
        
        self.init(requestID: requestID, token: token, primaryKey: primaryKey, attributes: attributes)
    }
}

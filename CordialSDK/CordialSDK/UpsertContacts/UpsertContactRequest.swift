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
    let subscribeStatus: String
    let attributes: Dictionary<String, String>?
    
    let cordialAPI = CordialAPI()
    
    enum Key: String {
        case token = "token"
        case primaryKey = "primaryKey"
        case subscribeStatus = "subscribeStatus"
        case attributes = "attributes"
    }
    
    private let baseSubscribeStatus = "none"

    public init(token: String) {
        self.deviceID = cordialAPI.getDeviceIdentifier()
        self.token = token
        self.primaryKey = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
        self.subscribeStatus = self.baseSubscribeStatus
        self.attributes = nil
    }
    
    public init(primaryKey: String?, attributes: Dictionary<String, String>?) {
        self.deviceID = cordialAPI.getDeviceIdentifier()
        self.token = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_TOKEN)
        self.primaryKey = primaryKey
        self.subscribeStatus = self.baseSubscribeStatus
        self.attributes = attributes
    }
    
    private init(token: String?, primaryKey: String?, subscribeStatus: String, attributes: Dictionary<String, String>?) {
        self.deviceID = cordialAPI.getDeviceIdentifier()
        self.token = token
        self.primaryKey = primaryKey
        self.subscribeStatus = subscribeStatus
        self.attributes = attributes
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(token, forKey: Key.token.rawValue)
        aCoder.encode(primaryKey, forKey: Key.primaryKey.rawValue)
        aCoder.encode(subscribeStatus, forKey: Key.subscribeStatus.rawValue)
        aCoder.encode(attributes, forKey: Key.attributes.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let token = aDecoder.decodeObject(forKey: Key.token.rawValue) as! String?
        let primaryKey = aDecoder.decodeObject(forKey: Key.primaryKey.rawValue) as! String?
        let subscribeStatus = aDecoder.decodeObject(forKey: Key.subscribeStatus.rawValue) as! String
        let attributes = aDecoder.decodeObject(forKey: Key.attributes.rawValue) as! Dictionary<String, String>?
        
        self.init(token: token, primaryKey: primaryKey, subscribeStatus: subscribeStatus, attributes: attributes)
    }
}

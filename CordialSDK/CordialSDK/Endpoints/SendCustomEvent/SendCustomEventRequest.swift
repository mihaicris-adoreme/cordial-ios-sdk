//
//  SendCustomEventRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/19/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

public class SendCustomEventRequest: NSObject, NSCoding {
    
    let deviceID: String
    let primaryKey: String?
    let eventName: String
    let timestamp: String
    let mcID: String?
    let properties: Dictionary<String, String>?
    
    let cordialAPI = CordialAPI()
    
    enum Key: String {
        case eventName = "eventName"
        case timestamp = "timestamp"
        case mcID = "mcID"
        case properties = "properties"
    }
    
    public init(eventName: String, properties: Dictionary<String, String>?) {
        self.deviceID = cordialAPI.getDeviceIdentifier()
        self.primaryKey = cordialAPI.getContactPrimaryKey()
        self.eventName = eventName
        self.timestamp = cordialAPI.getTimestamp()
        self.mcID = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID)
        self.properties = properties
    }
    
    private init(eventName: String, timestamp: String, mcID: String?, properties: Dictionary<String, String>?) {
        self.deviceID = cordialAPI.getDeviceIdentifier()
        self.primaryKey = cordialAPI.getContactPrimaryKey()
        self.eventName = eventName
        self.timestamp = timestamp
        self.mcID = mcID
        self.properties = properties
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(eventName, forKey: Key.eventName.rawValue)
        aCoder.encode(timestamp, forKey: Key.timestamp.rawValue)
        aCoder.encode(mcID, forKey: Key.mcID.rawValue)
        aCoder.encode(properties, forKey: Key.properties.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let eventName = aDecoder.decodeObject(forKey: Key.eventName.rawValue) as! String
        let timestamp = aDecoder.decodeObject(forKey: Key.timestamp.rawValue) as! String
        let mcID = aDecoder.decodeObject(forKey: Key.mcID.rawValue) as! String?
        let properties = aDecoder.decodeObject(forKey: Key.properties.rawValue) as! Dictionary<String, String>?
        
        self.init(eventName: eventName, timestamp: timestamp, mcID: mcID, properties: properties)
    }
    
}

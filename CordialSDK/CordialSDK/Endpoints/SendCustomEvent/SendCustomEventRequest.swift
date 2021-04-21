//
//  SendCustomEventRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/19/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class SendCustomEventRequest: NSObject, NSCoding {
    
    let requestID: String
    let eventName: String
    let timestamp: String
    let mcID: String?
    let latitude: Double?
    let longitude: Double?
    let properties: Dictionary<String, Any>?
    let primaryKey: String?
    
    var isError = false
        
    enum Key: String {
        case requestID = "requestID"
        case eventName = "eventName"
        case timestamp = "timestamp"
        case mcID = "mcID"
        case latitude = "latitude"
        case longitude = "longitude"
        case properties = "properties"
        case primaryKey = "primaryKey"
    }
    
    init(eventName: String, mcID: String?, properties: Dictionary<String, Any>?) {
        self.requestID = UUID().uuidString
        self.eventName = eventName
        self.timestamp = CordialDateFormatter().getCurrentTimestamp()
        self.mcID = mcID
        self.latitude = CordialLocationManager.shared.getLatitude()
        self.longitude = CordialLocationManager.shared.getLongitude()
        self.properties = properties
        self.primaryKey = CordialAPI().getContactPrimaryKey()
    }
    
    private init(requestID: String, eventName: String, timestamp: String, mcID: String?, latitude: Double?, longitude: Double?, properties: Dictionary<String, Any>?, primaryKey: String?) {
        self.requestID = requestID
        self.eventName = eventName
        self.timestamp = timestamp
        self.mcID = mcID
        self.latitude = latitude
        self.longitude = longitude
        self.properties = properties
        self.primaryKey = primaryKey
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.requestID, forKey: Key.requestID.rawValue)
        aCoder.encode(self.eventName, forKey: Key.eventName.rawValue)
        aCoder.encode(self.timestamp, forKey: Key.timestamp.rawValue)
        aCoder.encode(self.mcID, forKey: Key.mcID.rawValue)
        aCoder.encode(self.latitude, forKey: Key.latitude.rawValue)
        aCoder.encode(self.longitude, forKey: Key.longitude.rawValue)
        aCoder.encode(self.properties, forKey: Key.properties.rawValue)
        aCoder.encode(self.primaryKey, forKey: Key.primaryKey.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        if let requestID = aDecoder.decodeObject(forKey: Key.requestID.rawValue) as? String, let eventName = aDecoder.decodeObject(forKey: Key.eventName.rawValue) as? String, let timestamp = aDecoder.decodeObject(forKey: Key.timestamp.rawValue) as? String {
            let mcID = aDecoder.decodeObject(forKey: Key.mcID.rawValue) as! String?
            
            var latitude: Double?
            if let decodedLatitudeNumber = aDecoder.decodeObject(forKey: Key.latitude.rawValue) as? NSNumber {
                latitude = decodedLatitudeNumber.doubleValue
            }
            
            var longitude: Double?
            if let decodedLongitudeNumber = aDecoder.decodeObject(forKey: Key.longitude.rawValue) as? NSNumber {
                longitude = decodedLongitudeNumber.doubleValue
            }
            
            let properties = aDecoder.decodeObject(forKey: Key.properties.rawValue) as! Dictionary<String, Any>?
            
            let primaryKey = aDecoder.decodeObject(forKey: Key.primaryKey.rawValue) as! String?
            
            self.init(requestID: requestID, eventName: eventName, timestamp: timestamp, mcID: mcID, latitude: latitude, longitude: longitude, properties: properties, primaryKey: primaryKey)
        } else {
            self.init(requestID: String(), eventName: String(), timestamp: String(), mcID: nil, latitude: nil, longitude: nil, properties: nil, primaryKey: nil)
            
            self.isError = true
        }
    }
    
}

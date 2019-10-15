//
//  SendContactLogoutRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/17/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public class SendContactLogoutRequest: NSObject, NSCoding {
    
    let deviceID: String
    let primaryKey: String
    let requestID: String
    
    let internalCordialAPI = InternalCordialAPI()
    
    enum Key: String {
        case token = "token"
        case primaryKey = "primaryKey"
        case requestID = "requestID"
    }
    
    @objc public init(primaryKey: String) {
        self.deviceID = internalCordialAPI.getDeviceIdentifier()
        self.primaryKey = primaryKey
        self.requestID = UUID().uuidString
    }
    
    private init(primaryKey: String, requestID: String) {
        self.deviceID = internalCordialAPI.getDeviceIdentifier()
        self.primaryKey = primaryKey
        self.requestID = requestID
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.primaryKey, forKey: Key.primaryKey.rawValue)
        aCoder.encode(self.requestID, forKey: Key.requestID.rawValue)
    }
    
    @objc public required convenience init?(coder aDecoder: NSCoder) {
        let primaryKey = aDecoder.decodeObject(forKey: Key.primaryKey.rawValue) as! String
        let requestID = aDecoder.decodeObject(forKey: Key.requestID.rawValue) as! String
        
        self.init(primaryKey: primaryKey, requestID: requestID)
    }
}

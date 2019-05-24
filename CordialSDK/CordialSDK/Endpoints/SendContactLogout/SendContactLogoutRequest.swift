//
//  SendContactLogoutRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/17/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

public class SendContactLogoutRequest: NSObject, NSCoding {
    
    let deviceID: String
    let primaryKey: String
    
    let cordialAPI = CordialAPI()
    
    enum Key: String {
        case token = "token"
        case primaryKey = "primaryKey"
    }
    
    public init(primaryKey: String) {
        self.deviceID = cordialAPI.getDeviceIdentifier()
        self.primaryKey = primaryKey
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.primaryKey, forKey: Key.primaryKey.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let primaryKey = aDecoder.decodeObject(forKey: Key.primaryKey.rawValue) as! String
        
        self.init(primaryKey: primaryKey)
    }
}

//
//  SendContactLogoutRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/17/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public class SendContactLogoutRequest: NSObject, NSCoding {
    
    let requestID: String
    let primaryKey: String
    
    enum Key: String {
        case requestID = "requestID"
        case primaryKey = "primaryKey"
    }
    
    @objc public init(primaryKey: String) {
        self.requestID = UUID().uuidString
        self.primaryKey = primaryKey
    }
    
    private init(requestID: String, primaryKey: String) {
        self.requestID = requestID
        self.primaryKey = primaryKey
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.requestID, forKey: Key.requestID.rawValue)
        aCoder.encode(self.primaryKey, forKey: Key.primaryKey.rawValue)
    }
    
    @objc public required convenience init?(coder aDecoder: NSCoder) {
        let requestID = aDecoder.decodeObject(forKey: Key.requestID.rawValue) as! String
        let primaryKey = aDecoder.decodeObject(forKey: Key.primaryKey.rawValue) as! String
        
        self.init(requestID: requestID, primaryKey: primaryKey)
    }
}

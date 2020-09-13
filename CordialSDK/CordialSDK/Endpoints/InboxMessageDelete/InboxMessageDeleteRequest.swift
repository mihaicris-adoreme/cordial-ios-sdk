//
//  InboxMessageDeleteRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 10.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class InboxMessageDeleteRequest: NSObject, NSCoding {
    
    let requestID: String
    let primaryKey: String?
    let mcID: String
    
    var isError = false
    
    enum Key: String {
        case requestID = "requestID"
        case primaryKey = "primaryKey"
        case mcID = "mcID"
    }
    
    init(mcID: String) {
        self.requestID = UUID().uuidString
        
        if let primaryKey = CordialAPI().getContactPrimaryKey() {
            self.primaryKey = primaryKey
        } else if let contactKey = InternalCordialAPI().getContactKey() {
            self.primaryKey = contactKey
        } else {
            self.primaryKey = nil
        }
        
        self.mcID = mcID
    }
    
    private init(requestID: String, primaryKey: String?, mcID: String) {
        self.requestID = requestID
        self.primaryKey = primaryKey
        self.mcID = mcID
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.requestID, forKey: Key.requestID.rawValue)
        coder.encode(self.primaryKey, forKey: Key.primaryKey.rawValue)
        coder.encode(self.mcID, forKey: Key.mcID.rawValue)
    }
    
    required convenience init?(coder: NSCoder) {
        if let requestID = coder.decodeObject(forKey: Key.requestID.rawValue) as? String,
            let mcID = coder.decodeObject(forKey: Key.mcID.rawValue) as? String {
            
            let primaryKey = coder.decodeObject(forKey: Key.primaryKey.rawValue) as! String?
            
            self.init(requestID: requestID, primaryKey: primaryKey, mcID: mcID)
        } else {
            self.init(requestID: String(), primaryKey: String(), mcID: String())
            
            self.isError = true
        }
    }
    
}

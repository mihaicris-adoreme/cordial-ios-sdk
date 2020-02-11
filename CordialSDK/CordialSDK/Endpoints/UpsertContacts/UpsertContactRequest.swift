//
//  UpsertContactRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/6/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class UpsertContactRequest: NSObject, NSCoding {
    
    let requestID: String
    let token: String?
    let primaryKey: String?
    let status: String
    let attributes: Dictionary<String, String>?
    
    var isError = false
    
    enum Key: String {
        case requestID = "requestID"
        case token = "token"
        case primaryKey = "primaryKey"
        case status = "status"
        case attributes = "attributes"
    }
    
    init(token: String?, primaryKey: String?, status: String, attributes: Dictionary<String, String>?) {
        self.requestID = UUID().uuidString
        self.token = token
        self.primaryKey = primaryKey
        self.status = status
        self.attributes = attributes
    }
    
    private init(requestID: String, token: String?, primaryKey: String?, status: String, attributes: Dictionary<String, String>?) {
        self.requestID = requestID
        self.token = token
        self.primaryKey = primaryKey
        self.status = status
        self.attributes = attributes
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.requestID, forKey: Key.requestID.rawValue)
        aCoder.encode(self.token, forKey: Key.token.rawValue)
        aCoder.encode(self.primaryKey, forKey: Key.primaryKey.rawValue)
        aCoder.encode(self.status, forKey: Key.status.rawValue)
        aCoder.encode(self.attributes, forKey: Key.attributes.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        if let requestID = aDecoder.decodeObject(forKey: Key.requestID.rawValue) as? String, let status = aDecoder.decodeObject(forKey: Key.status.rawValue) as? String {
            let token = aDecoder.decodeObject(forKey: Key.token.rawValue) as! String?
            let primaryKey = aDecoder.decodeObject(forKey: Key.primaryKey.rawValue) as! String?
            
            let attributes = aDecoder.decodeObject(forKey: Key.attributes.rawValue) as! Dictionary<String, String>?
            
            self.init(requestID: requestID, token: token, primaryKey: primaryKey, status: status, attributes: attributes)
        } else {
            self.init(requestID: String(), token: nil, primaryKey: nil, status: String(), attributes: nil)
            
            self.isError = true
        }
    }
}

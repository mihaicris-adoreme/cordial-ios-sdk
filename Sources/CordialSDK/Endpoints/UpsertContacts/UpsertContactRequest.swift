//
//  UpsertContactRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/6/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class UpsertContactRequest: NSObject, NSCoding, NSSecureCoding {
    
    static var supportsSecureCoding = true
    
    let requestID: String
    let token: String?
    let primaryKey: String?
    let status: String
    let attributes: Dictionary<String, AttributeValue>?
    
    var isError = false
    
    enum Key: String {
        case requestID = "requestID"
        case primaryKey = "primaryKey"
        case status = "status"
        case attributes = "attributes"
    }
    
    init(token: String?, primaryKey: String?, status: String, attributes: Dictionary<String, AttributeValue>?) {
        self.requestID = UUID().uuidString
        self.token = token
        self.primaryKey = primaryKey
        self.status = status
        self.attributes = attributes
    }
    
    private init(requestID: String, primaryKey: String?, status: String, attributes: Dictionary<String, AttributeValue>?) {
        self.requestID = requestID
        self.token = InternalCordialAPI().getPushNotificationToken()
        self.primaryKey = primaryKey
        self.status = status
        self.attributes = attributes
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.requestID, forKey: Key.requestID.rawValue)
        coder.encode(self.primaryKey, forKey: Key.primaryKey.rawValue)
        coder.encode(self.status, forKey: Key.status.rawValue)
        coder.encode(self.attributes, forKey: Key.attributes.rawValue)
    }
    
    required convenience init?(coder: NSCoder) {
        if let requestID = coder.decodeObject(forKey: Key.requestID.rawValue) as? String,
           let status = coder.decodeObject(forKey: Key.status.rawValue) as? String,
           let primaryKey = coder.decodeObject(forKey: Key.primaryKey.rawValue) as? String?,
           let attributes = coder.decodeObject(forKey: Key.attributes.rawValue) as? Dictionary<String, AttributeValue>? {
            
            self.init(requestID: requestID, primaryKey: primaryKey, status: status, attributes: attributes)
        } else {
            self.init(requestID: String(), primaryKey: nil, status: String(), attributes: nil)
            
            self.isError = true
        }
    }
}

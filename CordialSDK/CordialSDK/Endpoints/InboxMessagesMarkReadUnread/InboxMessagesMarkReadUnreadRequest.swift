//
//  InboxMessagesMarkReadUnreadRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 03.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class InboxMessagesMarkReadUnreadRequest: NSObject, NSCoding {
    
    let requestID: String
    let primaryKey: String?
    let markAsReadMcIDs: [String]
    let markAsUnreadMcIDs: [String]
    
    var isError = false
    
    enum Key: String {
        case requestID = "requestID"
        case primaryKey = "primaryKey"
        case markAsReadMcIDs = "markAsReadMcIDs"
        case markAsUnreadMcIDs = "markAsUnreadMcIDs"
    }
    
    init(primaryKey: String?, markAsReadMcIDs: [String], markAsUnreadMcIDs: [String]) {
        self.requestID = UUID().uuidString
        self.primaryKey = primaryKey
        self.markAsReadMcIDs = markAsReadMcIDs
        self.markAsUnreadMcIDs = markAsUnreadMcIDs
    }
    
    private init(requestID: String, primaryKey: String?, markAsReadMcIDs: [String], markAsUnreadMcIDs: [String]) {
        self.requestID = requestID
        self.primaryKey = primaryKey
        self.markAsReadMcIDs = markAsReadMcIDs
        self.markAsUnreadMcIDs = markAsUnreadMcIDs
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.requestID, forKey: Key.requestID.rawValue)
        coder.encode(self.primaryKey, forKey: Key.primaryKey.rawValue)
        coder.encode(self.markAsReadMcIDs, forKey: Key.markAsReadMcIDs.rawValue)
        coder.encode(self.markAsUnreadMcIDs, forKey: Key.markAsUnreadMcIDs.rawValue)
    }
    
    required convenience init?(coder: NSCoder) {        
        if let requestID = coder.decodeObject(forKey: Key.requestID.rawValue) as? String,
            let markAsReadMcIDs = coder.decodeObject(forKey: Key.markAsReadMcIDs.rawValue) as? [String],
            let markAsUnreadMcIDs = coder.decodeObject(forKey: Key.markAsUnreadMcIDs.rawValue) as? [String] {
            
            let primaryKey = coder.decodeObject(forKey: Key.primaryKey.rawValue) as! String?
            
            self.init(requestID: requestID, primaryKey: primaryKey, markAsReadMcIDs: markAsReadMcIDs, markAsUnreadMcIDs: markAsUnreadMcIDs)
        } else {
            self.init(requestID: String(), primaryKey: String(), markAsReadMcIDs: [String](), markAsUnreadMcIDs: [String]())
            
            self.isError = true
        }
    }
}

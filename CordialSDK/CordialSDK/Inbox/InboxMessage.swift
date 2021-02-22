//
//  InboxMessage.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 28.08.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

@objc public class InboxMessage: NSObject, NSCoding {
    
    @objc public let mcID: String
    let url: String
    let urlExpireAt: Date
    @objc public let isRead: Bool
    @objc public let sentAt: Date
    @objc public let metadata: String
    
    var isError = false
    
    enum Key: String {
        case mcID = "mcID"
        case url = "url"
        case urlExpireAt = "urlExpireAt"
        case isRead = "isRead"
        case sentAt = "sentAt"
        case metadata = "metadata"
    }
    
    init(mcID: String, url: String, urlExpireAt: Date, isRead: Bool, sentAt: Date, metadata: String) {
        self.mcID = mcID
        self.url = url
        self.urlExpireAt = urlExpireAt
        self.isRead = isRead
        self.sentAt = sentAt
        self.metadata = metadata
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.mcID, forKey: Key.mcID.rawValue)
        coder.encode(self.url, forKey: Key.url.rawValue)
        coder.encode(self.urlExpireAt, forKey: Key.urlExpireAt.rawValue)
        coder.encode(self.isRead, forKey: Key.isRead.rawValue)
        coder.encode(self.sentAt, forKey: Key.sentAt.rawValue)
        coder.encode(self.metadata, forKey: Key.metadata.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        if let mcID = coder.decodeObject(forKey: Key.mcID.rawValue) as? String,
           let url = coder.decodeObject(forKey: Key.url.rawValue) as? String,
           let urlExpireAt = coder.decodeObject(forKey: Key.urlExpireAt.rawValue) as? Date,
           let sentAt = coder.decodeObject(forKey: Key.sentAt.rawValue) as? Date,
           let metadata = coder.decodeObject(forKey: Key.metadata.rawValue) as? String {
            
            let isRead = coder.decodeBool(forKey: Key.isRead.rawValue)
            
            self.init(mcID: mcID, url: url, urlExpireAt: urlExpireAt, isRead: isRead, sentAt: sentAt, metadata: metadata)
        } else {
            self.init(mcID: String(), url: String(), urlExpireAt: Date(), isRead: false, sentAt: Date(), metadata: String())
            
            self.isError = true
        }
    }
}

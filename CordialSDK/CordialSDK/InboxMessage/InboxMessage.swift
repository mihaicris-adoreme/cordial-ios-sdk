//
//  InboxMessage.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 28.08.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

@objc public class InboxMessage: NSObject {
    
    @objc public let id: String
    @objc public let html: String
    @objc public let customKeyValuePairs: [String: String]
    @objc public let title: String
    @objc public let read: Bool
    @objc public let sentAt: String
    
    init(id: String, html: String, customKeyValuePairs: [String: String], title: String, read: Bool, sentAt: String) {
        self.id = id
        self.html = html
        self.customKeyValuePairs = customKeyValuePairs
        self.title = title
        self.read = read
        self.sentAt = sentAt
    }
}

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
    @objc public let url: String
    @objc public let title: String
    @objc public let read: Bool
    @objc public let sentAt: String
    
    init(id: String, url: String, title: String, read: Bool, sentAt: String) {
        self.id = id
        self.url = url
        self.title = title
        self.read = read
        self.sentAt = sentAt
    }
}

//
//  InboxMessage.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 28.08.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

@objc public class InboxMessage: NSObject {
    
    @objc public let mcID: String
    @objc public let url: String
    @objc public let title: String
    @objc public let isRead: Bool
    @objc public let sentAt: String
    
    init(mcID: String, url: String, title: String, isRead: Bool, sentAt: String) {
        self.mcID = mcID
        self.url = url
        self.title = title
        self.isRead = isRead
        self.sentAt = sentAt
    }
}

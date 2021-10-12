//
//  InboxPage.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 14.10.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

@objc public class InboxPage: NSObject {
    
    @objc public let content: [InboxMessage]
    @objc public let total: Int
    @objc public let size: Int
    @objc public let current: Int
    @objc public let last: Int
    
    init(content: [InboxMessage], total: Int, size: Int, current: Int, last: Int) {
        self.content = content
        self.total = total
        self.size = size
        self.current = current
        self.last = last
    }
    
    @objc public func hasNext() -> Bool {
        if self.current < self.last {
            return true
        }
        
        return false
    }
    
}

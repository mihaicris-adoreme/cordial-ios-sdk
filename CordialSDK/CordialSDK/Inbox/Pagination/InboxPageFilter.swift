//
//  InboxPageFilter.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 19.10.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

@objc public class InboxPageFilter: NSObject {
    
    @objc public var isRead: InboxPageFilterIsReadType
    @objc public var fromDate: Date?
    @objc public var toDate: Date?
    
    public init(isRead: InboxPageFilterIsReadType, fromDate: Date?, toDate: Date?) {
        self.isRead = isRead
        self.fromDate = fromDate
        self.toDate = toDate
    }

}

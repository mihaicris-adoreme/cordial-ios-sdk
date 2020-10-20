//
//  InboxFilter.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 19.10.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

@objc public class InboxFilter: NSObject {
    
    @objc public var isRead: InboxFilterIsReadType
    @objc public var fromDate: Date?
    @objc public var toDate: Date?
    
    public init(isRead: InboxFilterIsReadType, fromDate: Date?, toDate: Date?) {
        self.isRead = isRead
        self.fromDate = fromDate
        self.toDate = toDate
    }

}

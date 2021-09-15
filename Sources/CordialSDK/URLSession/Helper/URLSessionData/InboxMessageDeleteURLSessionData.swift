//
//  InboxMessageDeleteURLSessionData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 14.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class InboxMessageDeleteURLSessionData {
    
    let inboxMessageDeleteRequest: InboxMessageDeleteRequest
    
    init(inboxMessageDeleteRequest: InboxMessageDeleteRequest) {
        self.inboxMessageDeleteRequest = inboxMessageDeleteRequest
    }
}

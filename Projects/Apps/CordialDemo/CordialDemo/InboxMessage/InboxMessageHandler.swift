//
//  InboxMessageHandler.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 24.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK

class InboxMessageHandler: InboxMessageDelegate {
    
    func newInboxMessageDelivered(mcID: String) {
        NotificationCenter.default.post(name: .cordialDemoNewInboxMessageDelivered, object: nil)
    }

}

//
//  InboxMessageHandler.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 21.12.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK

class InboxMessageHandler: InboxMessageDelegate {
    
    var isVerified = false
    var testMcID = String()
    
    func newInboxMessageDelivered(mcID: String) {
        if self.testMcID == mcID {
            self.isVerified = true
        }
    }

}

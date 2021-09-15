//
//  ContactTimestampData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 12.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

class ContactTimestampData {
    
    let inApp: Date?
    let inbox: Date?
    
    init(inApp: Date?, inbox: Date?) {
        self.inApp = inApp
        self.inbox = inbox
    }
    
}

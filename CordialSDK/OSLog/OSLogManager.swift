//
//  OSLogManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/9/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

extension OSLog {
    
    private static var subsystem = CoreDataManager.shared.identifier
    
    static let sendCustomEvents = OSLog(subsystem: subsystem, category: "SendCustomEvents")
    static let upsertContactCart = OSLog(subsystem: subsystem, category: "UpsertContactCart")
    static let sendContactOrders = OSLog(subsystem: subsystem, category: "SendContactOrders")
    static let upsertContacts = OSLog(subsystem: subsystem, category: "UpsertContacts")
    
}

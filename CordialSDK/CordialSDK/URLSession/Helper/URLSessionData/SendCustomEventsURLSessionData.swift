//
//  SendCustomEventsURLSessionData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/7/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class SendCustomEventsURLSessionData {
    
    let sendCustomEventRequests: [SendCustomEventRequest]
    
    init(sendCustomEventRequests: [SendCustomEventRequest]) {
        self.sendCustomEventRequests = sendCustomEventRequests
    }
}

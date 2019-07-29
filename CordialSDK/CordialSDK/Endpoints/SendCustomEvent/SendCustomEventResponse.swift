//
//  SendCustomEventResponse.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/19/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public class SendCustomEventResponse: NSObject {
    
    public let status: SendCustomEventStatus
    
    init(status: SendCustomEventStatus) {
        self.status = status
    }
    
    public enum SendCustomEventStatus: String {
        case SUCCESS
    }
    
}

//
//  SendContactOrderResponse.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/23/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public class SendContactOrderResponse: NSObject {
    
    public let status: SendContactOrderResponseStatus
    
    init(status: SendContactOrderResponseStatus) {
        self.status = status
    }
    
    public enum SendContactOrderResponseStatus: String {
        case SUCCESS
    }
    
}

//
//  SendContactOrderResponse.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/23/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

public class SendContactOrderResponse {
    
    public let status: SendContactOrderResponseStatus
    
    init(status: SendContactOrderResponseStatus) {
        self.status = status
    }
    
    public enum SendContactOrderResponseStatus: String {
        case SUCCESS
    }
    
}

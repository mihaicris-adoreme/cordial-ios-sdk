//
//  SendContactLogoutResponse.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/17/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public class SendContactLogoutResponse: NSObject {
    
    public let status: SendContactLogoutStatus
    
    init(status: SendContactLogoutStatus) {
        self.status = status
    }
    
    public enum SendContactLogoutStatus: String {
        case SUCCESS
    }
    
}

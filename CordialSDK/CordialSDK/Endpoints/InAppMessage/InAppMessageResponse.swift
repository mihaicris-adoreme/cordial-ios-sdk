//
//  InAppMessageResponse.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/3/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

public class InAppMessageResponse {
    
    public let status: InAppMessageStatus
    
    init(status: InAppMessageStatus) {
        self.status = status
    }
    
    public enum InAppMessageStatus: String {
        case SUCCESS
    }
    
}

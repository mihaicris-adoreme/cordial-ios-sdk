//
//  SendContactOrdersURLSessionData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class SendContactOrdersURLSessionData {
    
    let sendContactOrderRequests: [SendContactOrderRequest]
    
    init(sendContactOrderRequests: [SendContactOrderRequest]) {
        self.sendContactOrderRequests = sendContactOrderRequests
    }
}

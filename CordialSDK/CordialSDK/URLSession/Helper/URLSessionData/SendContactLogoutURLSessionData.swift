//
//  SendContactLogoutURLSessionData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class SendContactLogoutURLSessionData {
    
    let sendContactLogoutRequest: SendContactLogoutRequest
    
    init(sendContactLogoutRequest: SendContactLogoutRequest) {
        self.sendContactLogoutRequest = sendContactLogoutRequest
    }
}

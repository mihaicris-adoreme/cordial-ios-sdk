//
//  ThrottlerManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 27.10.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class ThrottlerManager {
    
    static let shared = ThrottlerManager()
    
    private init(){}
    
    let sendCustomEventRequest = Throttler(minimumDelay: 1)
    
}

//
//  InAppMessageInputsHandler.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 09.04.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK

class InAppMessageInputsHandler: InAppMessageInputsDelegate {
    
    func inputsCaptured(eventName: String, properties: Dictionary<String, Any>) {
        LoggerManager.shared.info(message: "IAM inputs successfully captured. Event name: [\(eventName)]. Properties: \(properties.description)", category: "CordialSDKDemo")
    }
    
}

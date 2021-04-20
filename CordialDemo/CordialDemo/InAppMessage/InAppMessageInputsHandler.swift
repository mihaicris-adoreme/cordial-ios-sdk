//
//  InAppMessageInputsHandler.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 09.04.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK
import os.log

class InAppMessageInputsHandler: InAppMessageInputsDelegate {
    
    func inputsCaptured(eventName: String, properties: Dictionary<String, String>) {
        os_log("IAM inputs successfully captured. Event name: [%{public}@]. Properties: %{public}@", log: OSLog.сordialSDKDemo, type: .info, eventName, properties.description)
    }
    
}

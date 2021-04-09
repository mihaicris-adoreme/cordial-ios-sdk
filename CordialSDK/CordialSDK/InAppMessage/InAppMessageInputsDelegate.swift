//
//  InAppMessageInputsDelegate.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 09.04.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

@objc public protocol InAppMessageInputsDelegate {
    
    @objc func inputsCaptured(eventName: String, properties: Dictionary<String, String>)
    
}

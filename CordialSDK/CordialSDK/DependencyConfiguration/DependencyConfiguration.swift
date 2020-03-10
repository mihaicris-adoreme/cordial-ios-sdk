//
//  DependencyConfiguration.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

@objc public class DependencyConfiguration: NSObject {
    
    @objc public static let shared = DependencyConfiguration()
    
    private override init(){}
    
    @objc public var requestSender = RequestSender()
    
}

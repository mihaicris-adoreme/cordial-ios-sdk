//
//  LoggerLevel.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 04.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation

@objc public enum LoggerLevel: Int {
    case none
    case all
    case error
    case info
}

@available(*, deprecated, message: "Use LoggerLevel instead")
@objc public enum logLevel: Int {
    case none
    case all
    case error
    case info
}

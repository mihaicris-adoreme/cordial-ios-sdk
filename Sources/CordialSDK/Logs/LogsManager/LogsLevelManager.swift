//
//  LogsLevelManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 04.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation

@objc public enum LogsLevel: Int {
    case none
    case all
    case error
    case info
}

@available(*, deprecated, message: "Use LogsLevel instead")
@objc public enum logLevel: Int {
    case none
    case all
    case error
    case info
}

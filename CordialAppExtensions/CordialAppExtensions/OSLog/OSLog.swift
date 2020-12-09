//
//  OSLog.swift
//  CordialAppExtensions
//
//  Created by Yan Malinovsky on 08.12.2020.
//  Copyright © 2020 Cordial Experience, Inc. All rights reserved.
//

import Foundation
import os.log

extension OSLog {
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let cordialAppExtensions = OSLog(subsystem: subsystem, category: "CordialSDKAppExtensions")
}

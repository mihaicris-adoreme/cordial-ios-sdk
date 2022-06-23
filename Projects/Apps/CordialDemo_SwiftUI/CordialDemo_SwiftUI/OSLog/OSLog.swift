//
//  OSLog.swift
//  CordialDemo_SwiftUI
//
//  Created by Yan Malinovsky on 16.05.2022.
//

import Foundation
import os.log

extension OSLog {
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let сordialSDKDemo = OSLog(subsystem: subsystem, category: "CordialSDKDemo")
    
}

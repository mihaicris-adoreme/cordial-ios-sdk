//
//  OSLogManager.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 28.08.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

extension OSLog {
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let сordialSDKDemo = OSLog(subsystem: subsystem, category: "CordialSDKDemo")
    
}

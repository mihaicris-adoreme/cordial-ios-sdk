//
//  OSLogManager.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 28.08.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK
import os.log

extension OSLog {
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let сordialSDKDemo = OSLog(subsystem: subsystem, category: "CordialSDKDemo")
}

// OSLog Category
//
// CordialSDKDemo

class OSLogManager: LoggerDelegate {
    
    static let shared = OSLogManager()
    
    private init() {}
    
    private let subsystem = Bundle.main.bundleIdentifier!
    private var categories: [String: OSLog] = [:]
    
    private func getOSLogCategory(category: String) -> OSLog {
        if let categoryOSLog = self.categories[category] {
            return categoryOSLog
        }
        
        let categoryOSLog = OSLog(subsystem: self.subsystem, category: category)
        self.categories[category] = categoryOSLog
        
        return categoryOSLog
    }
    
    // MARK: - LoggerDelegate
    
    func log(message: String, category: String) {
        os_log("%{public}@", log: self.getOSLogCategory(category: category), type: .default, message)
    }
    
    func info(message: String, category: String) {
        os_log("%{public}@", log: self.getOSLogCategory(category: category), type: .info, message)
    }
    
    func debug(message: String, category: String) {
        os_log("%{public}@", log: self.getOSLogCategory(category: category), type: .debug, message)
    }
    
    func error(message: String, category: String) {
        os_log("%{public}@", log: self.getOSLogCategory(category: category), type: .error, message)
    }
    
    func fault(message: String, category: String) {
        os_log("%{public}@", log: self.getOSLogCategory(category: category), type: .fault, message)
    }
}

//
//  LoggerManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 03.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation

@objcMembers public class LoggerManager: NSObject {
    
    public static let shared = LoggerManager()
    
    private override init() {}
    
    var loggerManagerLevel = LoggerLevel.error
    
    var loggers: [LoggerDelegate] = [OSLogManager.shared] 
    
    public func setLoggers(loggers: [LoggerDelegate]) {
        self.loggers = [OSLogManager.shared] + loggers
    }
    
    // MARK: - Logger manager
    
    public func log(message: String, category: String) {
        // Log level ignore LoggerLevel
        self.loggers.forEach { logger in
            logger.log(message: message, category: category)
        }
    }
    
    public func info(message: String, category: String) {
        if self.isLoggerAvailable(.info) {
            self.loggers.forEach { logger in
                logger.info(message: message, category: category)
            }
        }
    }
    
    public func debug(message: String, category: String) {
        if self.isLoggerAvailable() {
            self.loggers.forEach { logger in
                logger.debug(message: message, category: category)
            }
        }
    }
    
    public func error(message: String, category: String) {
        if self.isLoggerAvailable(.error) {
            self.loggers.forEach { logger in
                logger.error(message: message, category: category)
            }
        }
    }
    
    public func fault(message: String, category: String) {
        if self.isLoggerAvailable() {
            self.loggers.forEach { logger in
                logger.fault(message: message, category: category)
            }
        }
    }
    
    // MARK: - Logger level
    
    public func setLoggerLevel(_ loggerLevel: LoggerLevel) {
        switch loggerLevel {
        case .none:
            self.loggerManagerLevel = LoggerLevel.none
        case .all:
            self.loggerManagerLevel = LoggerLevel.all
        case .error:
            self.loggerManagerLevel = LoggerLevel.error
        case .info:
            self.loggerManagerLevel = LoggerLevel.info
        }
    }
    
    @available(*, deprecated, message: "Use setLoggerLevel instead")
    public func setLogLevel(_ logLevel: logLevel) {
        switch logLevel {
        case .none:
            self.setLoggerLevel(.none)
        case .all:
            self.setLoggerLevel(.all)
        case .error:
            self.setLoggerLevel(.error)
        case .info:
            self.setLoggerLevel(.info)
        }
    }
    
    @available(*, deprecated, message: "Use setLoggerLevel instead")
    public func setOSLogLevel(_ logLevel: logLevel) {
        switch logLevel {
        case .none:
            self.setLoggerLevel(.none)
        case .all:
            self.setLoggerLevel(.all)
        case .error:
            self.setLoggerLevel(.error)
        case .info:
            self.setLoggerLevel(.info)
        }
    }
    
    // MARK: - Logger availability
    
    private func isLoggerAvailable(_ loggerLevel: LoggerLevel = .all) -> Bool {
        switch self.loggerManagerLevel {
        case .none:
            return false
        case .all:
            return true
        case .error:
            if loggerLevel == .error {
                return true
            }
        case .info:
            if loggerLevel == .error || loggerLevel == .info {
                return true
            }
        }
        
        return false
    }
}

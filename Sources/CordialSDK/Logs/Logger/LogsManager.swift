//
//  LogsManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 03.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation
import os.log

@objcMembers public class LoggerManager: NSObject {
    
    static let shared = LoggerManager()
    
    private override init() {}
    
    var logsLevel = LoggerLevel.error
    
    var loggers: [LoggerDelegate] = [OSLogManager.shared] 
    
    // TMP
    func logging(_ message: StaticString, log: OSLog, type: LoggerLevel, _ args: CVarArg...) {
        if self.isAvailableOsLogLevelForPrint(type) {
            os_log(message, log: log, type: self.getLogType(type), args)
        }
    }
    
    // MARK: - Logs
    
    func log(message: String, category: String) {
        self.loggers.forEach { logger in
            logger.log(message: message, category: category)
        }
    }
    
    func info(message: String, category: String) {
        self.loggers.forEach { logger in
            logger.info(message: message, category: category)
        }
    }
    
    func debug(message: String, category: String) {
        self.loggers.forEach { logger in
            logger.debug(message: message, category: category)
        }
    }
    
    func error(message: String, category: String) {
        self.loggers.forEach { logger in
            logger.error(message: message, category: category)
        }
    }
    
    func fault(message: String, category: String) {
        self.loggers.forEach { logger in
            logger.fault(message: message, category: category)
        }
    }
    
    // MARK: - Logger level
    
    public func setLoggerLevel(_ loggerLevel: LoggerLevel) {
        switch loggerLevel {
        case .none:
            self.logsLevel = LoggerLevel.none
        case .all:
            self.logsLevel = LoggerLevel.all
        case .error:
            self.logsLevel = LoggerLevel.error
        case .info:
            self.logsLevel = LoggerLevel.info
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
    
    // MARK: - Is logging available
    
    func getLogType(_ loggerLevel: LoggerLevel) -> OSLogType {
        switch loggerLevel {
        case .error:
            return .error
        default:
            return .info
        }
    }
    
    func isAvailableOsLogLevelForPrint(_ loggerLevel: LoggerLevel) -> Bool {
        switch loggerLevel {
        case .none:
            return false
        case .all:
            return true
        case .error:
            return true
        case .info:
            if self.logsLevel == .info {
                return true
            }
        }
        
        return false
    }
}

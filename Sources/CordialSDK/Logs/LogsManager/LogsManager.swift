//
//  LogsManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 03.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation
import os.log

@objcMembers public class LogsManager: NSObject {
    
    static let shared = LogsManager()
    
    private override init() {}
    
    var logsLevel = LogsLevel.error
    
    var loggers: [LoggerDelegate] = [OSLogManager.shared] 
    
    // TMP
    func logging(_ message: StaticString, log: OSLog, type: LogsLevel, _ args: CVarArg...) {
        if self.isAvailableOsLogLevelForPrint(type) {
            os_log(message, log: log, type: self.getLogType(type), args)
        }
    }
    
    // MARK: - Logs
    
    func log(message: String) {
        self.loggers.forEach { logger in
            logger.log(message)
        }
    }
    
    func info(message: String) {
        self.loggers.forEach { logger in
            logger.info(message)
        }
    }
    
    func debug(message: String) {
        self.loggers.forEach { logger in
            logger.debug(message)
        }
    }
    
    func error(message: String) {
        self.loggers.forEach { logger in
            logger.error(message)
        }
    }
    
    func fault(message: String) {
        self.loggers.forEach { logger in
            logger.fault(message)
        }
    }
    
    // MARK: - Log level
    
    public func setLogLevel(_ logsLevel: LogsLevel) {
        switch logsLevel {
        case .none:
            self.logsLevel = LogsLevel.none
        case .all:
            self.logsLevel = LogsLevel.all
        case .error:
            self.logsLevel = LogsLevel.error
        case .info:
            self.logsLevel = LogsLevel.info
        }
    }
    
    @available(*, deprecated, message: "Use setLogLevel instead")
    public func setOSLogLevel(_ logsLevel: LogsLevel) {
        switch logsLevel {
        case .none:
            self.setLogLevel(.none)
        case .all:
            self.setLogLevel(.all)
        case .error:
            self.setLogLevel(.error)
        case .info:
            self.setLogLevel(.info)
        }
    }
    
    // MARK: - Is logging available
    
    func getLogType(_ logsLevel: LogsLevel) -> OSLogType {
        switch logsLevel {
        case .error:
            return .error
        default:
            return .info
        }
    }
    
    func isAvailableOsLogLevelForPrint(_ logsLevel: LogsLevel) -> Bool {
        switch logsLevel {
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

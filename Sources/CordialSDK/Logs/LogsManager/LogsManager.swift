//
//  LogsManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 03.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation

class LogsManager {
    
    var loggers: [LoggerDelegate] = []
    
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
}

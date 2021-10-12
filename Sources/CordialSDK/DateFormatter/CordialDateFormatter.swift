//
//  CordialDateFormatter.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.10.2019.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public class CordialDateFormatter: NSObject {
    
    let dateFormatter: ISO8601DateFormatter
    
    @objc public override init() {
        self.dateFormatter = ISO8601DateFormatter()
        self.dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    }

    @objc public func getCurrentTimestamp() -> String {
        let date = Date()
        
        return self.getTimestampFromDate(date: date)
    }

    @objc public func getDateFromTimestamp(timestamp: String) -> Date? {
        return self.dateFormatter.date(from: timestamp)
    }
    
    @objc public func getTimestampFromDate(date: Date) -> String {
        return self.dateFormatter.string(from: date)
    }
    
    @objc public func isValidTimestamp(timestamp: String) -> Bool {
        if let _ = self.getDateFromTimestamp(timestamp: timestamp) {
            return true
        }
        
        return false
    }
}

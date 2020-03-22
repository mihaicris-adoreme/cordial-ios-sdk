//
//  AppDateFormatter.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 22.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class AppDateFormatter {
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        return dateFormatter
    }()
    
    func getTimestampFromDate(date: Date) -> String {
        return self.dateFormatter.string(from: date)
    }
    
    func getDateFromTimestamp(timestamp: String) -> Date? {
        return self.dateFormatter.date(from: timestamp)
    }
}

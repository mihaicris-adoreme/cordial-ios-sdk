//
//  DateFormatter.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.10.2019.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class DateFormatter {
    
    let dateFormatter = ISO8601DateFormatter()

    func getCurrentTimestamp() -> String {
        let date = Date()
        
        return self.dateFormatter.string(from: date)
    }

    func getDateFromTimestamp(timestamp: String) -> Date? {
        return self.dateFormatter.date(from: timestamp)
    }
}

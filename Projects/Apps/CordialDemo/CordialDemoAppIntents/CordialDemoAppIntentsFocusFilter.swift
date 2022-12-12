//
//  CordialDemoAppIntentsFocusFilter.swift
//  CordialDemoAppIntents
//
//  Created by Yan Malinovsky on 12.12.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation
import AppIntents

struct CordialDemoAppIntentsFocusFilter: SetFocusFilterIntent {
    
    // Focus filter title
    static var title: LocalizedStringResource = "Focus Filter"
    
    // Focus filter description
    static var description: IntentDescription = "Select push notifications types to deliver."
    
    // MARK: - Filter information
    // Focus filter configurable parameters
    @Parameter(title: "Discounts", default: false)
    var isDiscounts: Bool
    
    @Parameter(title: "New Arrivals", default: false)
    var isNewArrivals: Bool
    
    @Parameter(title: "Top Products", default: false)
    var isTopProducts: Bool
    
    // The dynamic representation that displays after creating a Focus filter
    var displayRepresentation: DisplayRepresentation {
        let title = self.isDiscounts || self.isNewArrivals || self.isTopProducts ? "Choosed Filters:" : String()
        
        var filters = [String]()
        if self.isDiscounts { filters.append("Discounts") }
        if self.isNewArrivals { filters.append("New Arrivals") }
        if self.isTopProducts { filters.append("Top Products") }
        
        let subtitle = filters.joined(separator: ", ")
        
        return DisplayRepresentation(title: "\(title)", subtitle: "\(subtitle)")
    }
    
    // MARK: - Notification filtering and suppression
    // The system suppresses notifications from this app that include a filter criteria
    var appContext: FocusFilterAppContext {
        let predicate: NSPredicate
        // Evaluate the predicate against parameters from this instance.
        
        // TMP
        if self.isDiscounts {
            // Suppress notifications
            
            // TMP
            predicate = NSPredicate(format: "SELF IN %@", ["discounts"])
        } else {
            // Do not suppress notifications
            predicate = NSPredicate(value: true)
        }
        return FocusFilterAppContext(notificationFilterPredicate: predicate)
    }
    
    // MARK: - Perform function
    // The system calls this function when enabling or disabling Focus.
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

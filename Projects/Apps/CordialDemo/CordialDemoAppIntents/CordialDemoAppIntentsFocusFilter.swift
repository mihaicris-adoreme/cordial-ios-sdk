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
    
    // Focus filter configurable parameters
    @Parameter(title: "Discounts", default: false)
    var isDiscounts: Bool
    
    @Parameter(title: "New Arrivals", default: false)
    var isNewArrivals: Bool
    
    @Parameter(title: "Top Products", default: false)
    var isTopProducts: Bool
    
    // Focus filter information
    static var title: LocalizedStringResource = "Focus Filter"
    
    // The dynamic representation that displays after creating a Focus filter
    var displayRepresentation: DisplayRepresentation {
        let title = self.isDiscounts || self.isNewArrivals || self.isTopProducts ? "Choosed Filters:" : String()
        
        var filters = [String]()
        if self.isDiscounts { filters.append("Discounts") }
        if self.isNewArrivals { filters.append("New Arrivals") }
        if self.isTopProducts { filters.append("Top Products") }
        
        let subtitle = filters.joined(separator: ", ")
        
        return DisplayRepresentation(title: "\(title)",
                              subtitle: "\(subtitle)")
    }
    
    // The system calls this function when enabling or disabling Focus mode
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

//
//  CordialDemoAppIntents.swift
//  CordialDemoAppIntents
//
//  Created by Yan Malinovsky on 12.12.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import AppIntents

struct CordialDemoAppIntents: AppIntent {
    static var title: LocalizedStringResource = "CordialDemoAppIntents"
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

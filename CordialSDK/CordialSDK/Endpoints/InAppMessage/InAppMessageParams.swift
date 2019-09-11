//
//  InAppMessageParams.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 9/10/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

struct InAppMessageParams {
    let mcID: String
    let date: Date
    
    init(mcID: String, date: Date) {
        self.mcID = mcID
        self.date = date
    }
}

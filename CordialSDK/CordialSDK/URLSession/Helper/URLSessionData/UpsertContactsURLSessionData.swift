//
//  UpsertContactsURLSessionData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class UpsertContactsURLSessionData {
    
    let upsertContactRequests: [UpsertContactRequest]
    
    init(upsertContactRequests: [UpsertContactRequest]) {
        self.upsertContactRequests = upsertContactRequests
    }
}

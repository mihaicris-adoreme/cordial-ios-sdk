//
//  UpsertContactCartResponse.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/18/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

public class UpsertContactCartResponse {
    
    public let status: UpsertContactCartResponseStatus
    
    init(status: UpsertContactCartResponseStatus) {
        self.status = status
    }
    
    public enum UpsertContactCartResponseStatus: String {
        case SUCCESS
    }
    
}

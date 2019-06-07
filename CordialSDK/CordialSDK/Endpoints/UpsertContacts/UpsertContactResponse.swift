//
//  UpsertContactResponse.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/6/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

public class UpsertContactResponse {
    
    public let status: UpsertContactStatus
    
    init(status: UpsertContactStatus) {
        self.status = status
    }
    
    public enum UpsertContactStatus: String {
        case SUCCESS
    }
    
}

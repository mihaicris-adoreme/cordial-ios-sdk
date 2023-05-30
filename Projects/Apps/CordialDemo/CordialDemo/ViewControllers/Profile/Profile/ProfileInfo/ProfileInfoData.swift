//
//  ProfileInfoData.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 23.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation

struct ProfileInfoData {
    
    let key: String
    let value: String
    let type: String?
    
    init(key: String, value: String, type: String? = nil) {
        self.key = key
        self.value = value
        self.type = type
    }
}

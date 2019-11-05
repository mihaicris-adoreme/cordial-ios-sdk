//
//  Credentials.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 08.10.2019.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

struct Credentials {
    let baseURL: String
    let accountKey: String
    let channelKey: String
    
    init(baseURL: String, accountKey: String, channelKey: String) {
        self.baseURL = baseURL
        self.accountKey = accountKey
        self.channelKey = channelKey
    }
}

//
//  Credentials.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 08.10.2019.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

struct Credentials {
    let eventsStreamURL: String
    let messageHubURL: String
    let accountKey: String
    let channelKey: String
    
    init(eventsStreamURL: String, messageHubURL: String, accountKey: String, channelKey: String) {
        self.eventsStreamURL = eventsStreamURL
        self.messageHubURL = messageHubURL
        self.accountKey = accountKey
        self.channelKey = channelKey
    }
}

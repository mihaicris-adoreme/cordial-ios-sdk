//
//  PushNotificationCategory.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 09.02.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation

@objcMembers public class PushNotificationCategory: NSObject, NSCoding {
    
    let key: String
    let name: String
    let initState: Bool
    
    var isError = false
    
    enum Key: String {
        case key = "key"
        case name = "name"
        case initState = "initState"
    }
    
    public init(key: String, name: String, initState: Bool) {
        self.key = key
        self.name = name
        self.initState = initState
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.key, forKey: Key.key.rawValue)
        coder.encode(self.name, forKey: Key.name.rawValue)
        coder.encode(self.initState, forKey: Key.initState.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        if let key = coder.decodeObject(forKey: Key.key.rawValue) as? String,
           let name = coder.decodeObject(forKey: Key.name.rawValue) as? String {
            
            let initState = coder.decodeBool(forKey: Key.initState.rawValue)
            
            self.init(key: key, name: name, initState: initState)
        } else {
            self.init(key: String(), name: String(), initState: true)
            
            self.isError = true
        }
    }
}

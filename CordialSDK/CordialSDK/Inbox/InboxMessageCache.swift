//
//  InboxMessageCache.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 11.11.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

@objc public class InboxMessageCache: NSObject {
    
    static let shared = InboxMessageCache()
    
    private override init() {}
    
    @objc public var maxCacheSize = 2 * 1024 * 1024
    @objc public var maxCachableMessageSize = 50 * 1024
    
}

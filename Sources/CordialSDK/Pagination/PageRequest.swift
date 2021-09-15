//
//  PageRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 14.10.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

@objc public class PageRequest: NSObject {
    
    var page: Int
    var size: Int
    
    @objc public init(page: Int, size: Int) {
        self.page = page
        self.size = size
    }
    
    @objc public func next() -> PageRequest {
        self.page += 1
        
        return self
    }
    
    @objc public func previous() -> PageRequest {
        if self.page > 1 {
            self.page -= 1
        }
            
        return self
    }
    
}

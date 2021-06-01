//
//  CordialURLSessionConfigurationHandler.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 26.05.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

@objc public class CordialURLSessionConfigurationHandler: NSObject {
    
    @objc public func isCordialURLSession(identifier: String) -> Bool {
        if identifier == API.BACKGROUND_URL_SESSION_IDENTIFIER {
            return true
        }
        
        return false
    }
    
    @objc public func processURLSessionCompletionHandler(identifier: String, completionHandler: @escaping () -> Void) {
        CordialSwizzlerHelper().swizzleAppHandleEventsForBackgroundURLSessionCompletionHandler(identifier: identifier, completionHandler: completionHandler)
    }
}

//
//  CordialSwiftUIAppDeepLinksHandler.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 18.06.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import os.log

public class CordialSwiftUIAppDeepLinksHandler {
    
    public init() {}
    
    public func processDeepLink(url: URL, completionHandler: @escaping (_ response: URL) -> Void) {
        InternalCordialAPI().sentEventDeepLinkOpen()
        
        CordialEmailDeepLink().getDeepLink(url: url, onSuccess: { url in
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Email DeepLink converted successfully", log: OSLog.cordialDeepLinks, type: .info)
            }
            
            completionHandler(url)
            
        }, onFailure: { error in
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Email DeepLink opening failed. Error: [%{public}@]", log: OSLog.cordialDeepLinks, type: .error, error)
            }
            
            completionHandler(url)
        })
    }
}

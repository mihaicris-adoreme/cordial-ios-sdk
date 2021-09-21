//
//  CordialSwiftUIDeepLinksHandler.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 18.06.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import os.log

public class CordialSwiftUIDeepLinksHandler {
    
    public init() {}
    
    @available(iOS 13.0, *)
    public func processDeepLink(url: URL) {
        InternalCordialAPI().sentEventDeepLinkOpen()
        
        CordialVanityDeepLink().getDeepLink(url: url, onSuccess: { url in
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Vanity DeepLink converted successfully", log: OSLog.cordialDeepLinks, type: .info)
            }
            
            CordialSwiftUIDeepLinksPublisher.shared.publishDeepLink(url: url, fallbackURL: nil)
            
        }, onFailure: { error in
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Vanity DeepLink opening failed. Error: [%{public}@]", log: OSLog.cordialDeepLinks, type: .error, error)
            }
            
            CordialSwiftUIDeepLinksPublisher.shared.publishDeepLink(url: url, fallbackURL: nil)
        })
    }
}

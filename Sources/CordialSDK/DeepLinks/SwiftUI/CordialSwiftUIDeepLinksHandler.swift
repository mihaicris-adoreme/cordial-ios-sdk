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
        DispatchQueue.main.async {
            NotificationManager.shared.originDeepLink = url.absoluteString
            
            InternalCordialAPI().sentEventDeepLinkOpen(url: url)
            
            CordialVanityDeepLink().getDeepLink(url: url, onSuccess: { url in
                CordialSwiftUIDeepLinksPublisher.shared.publishDeepLink(url: url, fallbackURL: nil, completionHandler: { deepLinkActionType in

                    InternalCordialAPI().deepLinkAction(deepLinkActionType: deepLinkActionType)
                })
                
                NotificationManager.shared.vanityDeepLink = String()
                
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Vanity DeepLink converted successfully", log: OSLog.cordialDeepLinks, type: .info)
                }
            }, onFailure: { error in
                if !NotificationManager.shared.vanityDeepLink.isEmpty, let vanityDeepLinkURL = URL(string: NotificationManager.shared.vanityDeepLink) {
                    CordialSwiftUIDeepLinksPublisher.shared.publishDeepLink(url: vanityDeepLinkURL, fallbackURL: nil, completionHandler: { deepLinkActionType in
                        
                        InternalCordialAPI().deepLinkAction(deepLinkActionType: deepLinkActionType)
                    })
                } else {
                    CordialSwiftUIDeepLinksPublisher.shared.publishDeepLink(url: url, fallbackURL: nil, completionHandler: { deepLinkActionType in
                        
                        InternalCordialAPI().deepLinkAction(deepLinkActionType: deepLinkActionType)
                    })
                }
                
                NotificationManager.shared.vanityDeepLink = String()
                
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("Vanity DeepLink opening failed. Error: [%{public}@]", log: OSLog.cordialDeepLinks, type: .error, error)
                }
            })
        }
    }
}

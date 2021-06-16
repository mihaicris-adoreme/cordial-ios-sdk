//
//  CordialDeepLinksAPI.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 01.02.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import os.log

@objc public class CordialDeepLinksAPI: NSObject {
    
    @objc public func openAppDelegateUniversalLink(userActivity: NSUserActivity) {
        let _ = CordialSwizzler.shared.application(UIApplication.shared, continue: userActivity, restorationHandler: { _ in })
    }
    
    @available(iOS 13.0, *)
    @objc public func openSceneDelegateUniversalLink(scene: UIScene, userActivity: NSUserActivity) {
        CordialSwizzler.shared.scene(scene, continue: userActivity)
    }
    
    public func openSwiftUIAppDeepLink(url: URL, completionHandler: @escaping (_ response: URL) -> Void) {
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

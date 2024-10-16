//
//  CordialDeepLinksAPI.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 01.02.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import UIKit

@objc public class CordialDeepLinksAPI: NSObject {
    
    @objc public func openAppDelegateUniversalLink(userActivity: NSUserActivity) {
        let _ = CordialSwizzler.shared.application(UIApplication.shared, continue: userActivity, restorationHandler: { _ in })
    }
    
    @available(iOS 13.0, *)
    @objc public func openSceneDelegateUniversalLink(scene: UIScene, userActivity: NSUserActivity) {
        CordialSwizzler.shared.scene(scene, continue: userActivity)
    }
    
}

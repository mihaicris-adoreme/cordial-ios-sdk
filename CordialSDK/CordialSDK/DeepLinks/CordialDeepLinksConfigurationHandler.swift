//
//  CordialDeepLinksConfigurationHandler.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 25.05.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

@objc public class CordialDeepLinksConfigurationHandler: NSObject {
    
    @objc public func processAppContinueRestorationHandler(userActivity: NSUserActivity) -> Bool {
        return CordialSwizzlerHelper().processAppContinueRestorationHandler(userActivity: userActivity)
    }

    @objc public func processAppOpenOptions(url: URL) -> Bool {
        return CordialSwizzlerHelper().processAppOpenOptions(url: url)
    }
    
    @available(iOS 13.0, *)
    @objc public func processSceneContinue(userActivity: NSUserActivity, scene: UIScene) {
        CordialSwizzlerHelper().processSceneContinue(userActivity: userActivity, scene: scene)
    }
    
    @available(iOS 13.0, *)
    @objc public func processSceneOpenURLContexts(URLContexts: Set<UIOpenURLContext>, scene: UIScene) {
        CordialSwizzlerHelper().processSceneOpenURLContexts(URLContexts: URLContexts, scene: scene)
    }
}

//
//  NotificationSettingsHandler.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 13.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class NotificationSettingsHandler: PushNotificationCategoriesDelegate {
    
    func openPushNotificationCategories() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let catalogNavigationController = storyboard.instantiateViewController(withIdentifier: "CatalogNavigationController") as! UINavigationController
        
        let notificationSettingsController = NotificationSettingsViewController()
        
        catalogNavigationController.pushViewController(notificationSettingsController, animated: false)
        
        if #available(iOS 13.0, *), self.isAppUseScenes() {
            if let scene = UIApplication.shared.connectedScenes.first,
               let sceneDelegate = scene.delegate as? SceneDelegate {
                
                sceneDelegate.window?.rootViewController = catalogNavigationController
            }
        } else {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.window?.rootViewController = catalogNavigationController
            }
        }
    }
    
    // MARK: - Checking app for use scenes
    
    func isAppUseScenes() -> Bool {
        let delegateClass: AnyClass! = object_getClass(UIApplication.shared.delegate)
        
        var methodCount: UInt32 = 0
        let methodList = class_copyMethodList(delegateClass, &methodCount)
        
        if var methodList = methodList, methodCount > 0 {
            for _ in 0..<methodCount {
                let method = methodList.pointee
                
                let selector = method_getName(method)
                let selectorName = String(cString: sel_getName(selector))
                
                let connectingSceneSessionSelectorName = "application:configurationForConnectingSceneSession:options:"
                
                if selectorName == connectingSceneSessionSelectorName {
                    return true
                }
                
                methodList = methodList.successor()
            }
        }
        
        return false
    }
}

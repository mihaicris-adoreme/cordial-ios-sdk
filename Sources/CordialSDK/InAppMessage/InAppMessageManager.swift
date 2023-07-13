//
//  InAppMessageManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 6/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit

class InAppMessageManager {
    
    private var inAppMessageViewController: InAppMessageViewController!
    
    func getInAppMessageViewController() -> InAppMessageViewController {
        return self.inAppMessageViewController
    }
    
    func getModalWebViewController(topViewController: UIViewController, inAppMessageData: InAppMessageData) -> InAppMessageViewController {
        self.inAppMessageViewController = InAppMessageViewController()
        
        self.inAppMessageViewController.isBanner = false
        
        self.prepareModalInAppMessage(inAppMessageData: inAppMessageData)
        
        self.inAppMessageViewController.view.frame = topViewController.view.bounds
        
        return self.inAppMessageViewController
    }
    
    private func prepareModalInAppMessage(inAppMessageData: InAppMessageData) {
        self.inAppMessageViewController.initWebView(inAppMessageData: inAppMessageData)
        
        self.inAppMessageViewController.view.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
    }
    
    func getBannerViewController(topViewController: UIViewController, inAppMessageData: InAppMessageData) -> InAppMessageViewController {
        self.inAppMessageViewController = InAppMessageViewController()
        
        self.inAppMessageViewController.isBanner = true
        
        self.prepareBannerInAppMessage(inAppMessageData: inAppMessageData)
        
        self.inAppMessageViewController.view.frame = topViewController.view.bounds
        
        return self.inAppMessageViewController
    }
    
    private func prepareBannerInAppMessage(inAppMessageData: InAppMessageData) {        
        self.inAppMessageViewController.initWebView(inAppMessageData: inAppMessageData)
        
        self.inAppMessageViewController.view.layer.shadowColor = UIColor.gray.cgColor
        self.inAppMessageViewController.view.layer.shadowOpacity = 1
        self.inAppMessageViewController.view.layer.shadowOffset = .zero
        self.inAppMessageViewController.view.layer.shadowRadius = 10
    }
    
    func isTopViewControllerCanPresentInAppMessage(topViewController: UIViewController) -> Bool {
        var topViewController = topViewController
        
        switch CordialApiConfiguration.shared.inAppMessageDelayMode.currentMode {
        case InAppMessageDelayType.show:
            return true
        case InAppMessageDelayType.delayedShow:
            return false
        case InAppMessageDelayType.disallowedControllers:
            switch topViewController {
            case is UINavigationController:
                let navigationController = topViewController as! UINavigationController
                guard let navigationTopViewController = navigationController.topViewController else { return false }
                
                topViewController = navigationTopViewController
            case is UITabBarController:
                let tabBarController = topViewController as! UITabBarController
                guard let tabBarSelectedViewController = tabBarController.selectedViewController else { return false }
                
                topViewController = tabBarSelectedViewController
            default:
                break
            }
            
            for controllerType in CordialApiConfiguration.shared.inAppMessageDelayMode.disallowedControllersType {
                if type(of: topViewController) === controllerType {
                    return false
                }
            }
        }
        
        return true
    }
}

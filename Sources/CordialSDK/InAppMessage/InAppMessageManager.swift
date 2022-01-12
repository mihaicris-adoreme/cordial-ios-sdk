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
    
    func getModalWebViewController(activeViewController: UIViewController, inAppMessageData: InAppMessageData) -> InAppMessageViewController {
        self.inAppMessageViewController = InAppMessageViewController()
        
        self.inAppMessageViewController.isBanner = false
        
        self.prepareModalInAppMessage(inAppMessageData: inAppMessageData)
        
        self.inAppMessageViewController.view.frame = activeViewController.view.bounds
        
        return self.inAppMessageViewController
    }
    
    private func prepareModalInAppMessage(inAppMessageData: InAppMessageData) {
        self.inAppMessageViewController.initWebView(inAppMessageData: inAppMessageData)
        
        self.inAppMessageViewController.view.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
    }
    
    func getBannerViewController(activeViewController: UIViewController, inAppMessageData: InAppMessageData) -> InAppMessageViewController {
        self.inAppMessageViewController = InAppMessageViewController()
        
        self.inAppMessageViewController.isBanner = true
        
        self.prepareBannerInAppMessage(inAppMessageData: inAppMessageData)
        
        self.inAppMessageViewController.view.frame = activeViewController.view.bounds
        
        return self.inAppMessageViewController
    }
    
    private func prepareBannerInAppMessage(inAppMessageData: InAppMessageData) {        
        self.inAppMessageViewController.initWebView(inAppMessageData: inAppMessageData)
        
        self.inAppMessageViewController.view.layer.shadowColor = UIColor.gray.cgColor
        self.inAppMessageViewController.view.layer.shadowOpacity = 1
        self.inAppMessageViewController.view.layer.shadowOffset = .zero
        self.inAppMessageViewController.view.layer.shadowRadius = 10
    }
    
    func isActiveViewControllerCanPresentInAppMessage(activeViewController: UIViewController?) -> Bool {
        var topViewController: UIViewController?
        
        switch activeViewController {
        case is UINavigationController:
            let navigationController = activeViewController as! UINavigationController
            topViewController = navigationController.viewControllers.last!
        case is UITabBarController:
            let tabBarController = activeViewController as! UITabBarController
            topViewController = tabBarController.selectedViewController
        default:
            topViewController = activeViewController
        }
        
        if let topViewController = topViewController {
            switch CordialApiConfiguration.shared.inAppMessageDelayMode.currentMode {
            case InAppMessageDelayType.show:
                return true
            case InAppMessageDelayType.delayedShow:
                return false
            case InAppMessageDelayType.disallowedControllers:
                for controllerType in CordialApiConfiguration.shared.inAppMessageDelayMode.disallowedControllersType {
                    if type(of: topViewController) === controllerType {
                        return false
                    }
                }
            }
        }
        
        return true
    }
}

//
//  InAppMessageManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 6/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class InAppMessageManager {
    
    var inAppMessageViewController: InAppMessageViewController!
    
    func getModalWebViewController(activeViewController: UIViewController, inAppMessageData: InAppMessageData) -> InAppMessageViewController {
        self.inAppMessageViewController = InAppMessageViewController()
        
        self.inAppMessageViewController.isBanner = false
        
        self.inAppMessageViewController.inAppMessageData = inAppMessageData
        
        self.prepareModalInAppMessage(inAppMessageData: inAppMessageData)
        
        self.inAppMessageViewController.view.frame = activeViewController.view.bounds
        
        return self.inAppMessageViewController
    }
    
    private func prepareModalInAppMessage(inAppMessageData: InAppMessageData) {
        let screenBounds = UIScreen.main.bounds
        
        let width = screenBounds.size.width - screenBounds.size.width * (CGFloat(inAppMessageData.left) / 100 + CGFloat(inAppMessageData.right) / 100)
        let height = screenBounds.size.height - screenBounds.size.height * (CGFloat(inAppMessageData.top) / 100 + CGFloat(inAppMessageData.bottom) / 100)
        
        let size = CGSize(width: width, height: height)
        
        let x = (screenBounds.size.width - width) / 2
        let y = (screenBounds.size.height - height) / 2
        let origin = CGPoint(x: x, y: y)
        
        let inAppMessageSize = CGRect(origin: origin, size: size)
        
        self.inAppMessageViewController.initWebView(webViewSize: inAppMessageSize, mcID: inAppMessageData.mcID)
        
        self.inAppMessageViewController.view.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
    }
    
    func getBannerViewController(activeViewController: UIViewController, inAppMessageData: InAppMessageData) -> InAppMessageViewController {
        self.inAppMessageViewController = InAppMessageViewController()
        
        self.inAppMessageViewController.isBanner = true
        
        self.inAppMessageViewController.inAppMessageData = inAppMessageData
        
        self.prepareBannerInAppMessage(inAppMessageData: inAppMessageData)
        
        self.inAppMessageViewController.view.frame = activeViewController.view.bounds
        
        return self.inAppMessageViewController
    }
    
    private func prepareBannerInAppMessage(inAppMessageData: InAppMessageData) {
        let screenBounds = UIScreen.main.bounds
        
        let width = screenBounds.size.width - screenBounds.size.width * (CGFloat(inAppMessageData.left) / 100 + CGFloat(inAppMessageData.right) / 100)
        let height = screenBounds.size.height - screenBounds.size.height * (CGFloat(inAppMessageData.top) / 100 + CGFloat(inAppMessageData.bottom) / 100)
        
        let size = CGSize(width: width, height: height)
        
        let x = (screenBounds.size.width - width) / 2
        var y = CGFloat()
        switch inAppMessageData.type {
        case InAppMessageType.banner_up:
            y = screenBounds.size.height * CGFloat(inAppMessageData.top) / 100.0
        case InAppMessageType.banner_bottom:
            y = screenBounds.size.height * CGFloat(inAppMessageData.top) / 100.0
        default: break
        }
        
        let origin = CGPoint(x: x, y: y)
        
        let inAppMessageSize = CGRect(origin: origin, size: size)
        
        self.inAppMessageViewController.initWebView(webViewSize: inAppMessageSize, mcID: inAppMessageData.mcID)
        
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
            switch CordialApiConfiguration.shared.inAppMessageDelayModes.currentMode {
            case InAppMessageDelayType.show:
                return true
            case InAppMessageDelayType.delayedShow:
                return false
            case InAppMessageDelayType.disallowedControllers:
                for controllerType in CordialApiConfiguration.shared.inAppMessageDelayModes.disallowedControllersType {
                    if type(of: topViewController) === controllerType {
                        return false
                    }
                }
            }
        }
        
        return true
    }
}

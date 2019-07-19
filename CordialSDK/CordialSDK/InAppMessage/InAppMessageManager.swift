//
//  InAppMessageManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 6/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class InAppMessageManager {
    
    func getModalWebViewController(activeViewController: UIViewController, inAppMessageData: InAppMessageData) -> InAppMessageViewController {
        let inAppMessageViewController = InAppMessageViewController()
        inAppMessageViewController.isBanner = false
        
        inAppMessageViewController.inAppMessageData = inAppMessageData
        
        self.prepareModalInAppMessage(inAppMessageViewController: inAppMessageViewController, inAppMessageData: inAppMessageData)
        
        inAppMessageViewController.view.frame = activeViewController.view.bounds
        
        return inAppMessageViewController
    }
    
    private func prepareModalInAppMessage(inAppMessageViewController: InAppMessageViewController, inAppMessageData: InAppMessageData) {
        let screenBounds = UIScreen.main.bounds
        
        let width = screenBounds.size.width - screenBounds.size.width * (CGFloat(inAppMessageData.left) / 100 + CGFloat(inAppMessageData.right) / 100)
        let height = screenBounds.size.height - screenBounds.size.height * (CGFloat(inAppMessageData.top) / 100 + CGFloat(inAppMessageData.bottom) / 100)
        
        let size = CGSize(width: width, height: height)
        
        let x = (screenBounds.size.width - width) / 2
        let y = (screenBounds.size.height - height) / 2
        let origin = CGPoint(x: x, y: y)
        
        let inAppMessageSize = CGRect(origin: origin, size: size)
        
        inAppMessageViewController.initWebView(webViewSize: inAppMessageSize)
        
        inAppMessageViewController.view.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
    }
    
    func getBannerViewController(activeViewController: UIViewController, inAppMessageData: InAppMessageData) -> InAppMessageViewController {
        let inAppMessageViewController = InAppMessageViewController()
        inAppMessageViewController.isBanner = true
        
        inAppMessageViewController.inAppMessageData = inAppMessageData
        
        self.prepareBannerInAppMessage(inAppMessageViewController: inAppMessageViewController, inAppMessageData: inAppMessageData)
        
        inAppMessageViewController.view.frame = activeViewController.view.bounds
        
        return inAppMessageViewController
    }
    
    private func prepareBannerInAppMessage(inAppMessageViewController: InAppMessageViewController, inAppMessageData: InAppMessageData) {
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
        
        inAppMessageViewController.initWebView(webViewSize: inAppMessageSize)
        
        inAppMessageViewController.view.layer.shadowColor = UIColor.gray.cgColor
        inAppMessageViewController.view.layer.shadowOpacity = 1
        inAppMessageViewController.view.layer.shadowOffset = .zero
        inAppMessageViewController.view.layer.shadowRadius = 10
        
    }
}

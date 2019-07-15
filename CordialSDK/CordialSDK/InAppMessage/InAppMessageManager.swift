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
        
        inAppMessageViewController.modalPresentationStyle = .overCurrentContext
        inAppMessageViewController.modalTransitionStyle = .crossDissolve

        self.prepareModalInAppMessageSize(activeViewController: activeViewController, inAppMessageViewController: inAppMessageViewController, inAppMessageData: inAppMessageData)
        
        inAppMessageViewController.webView.loadHTMLString(inAppMessageData.html, baseURL: nil)
        
        return inAppMessageViewController
    }
    
    private func prepareModalInAppMessageSize(activeViewController: UIViewController, inAppMessageViewController: InAppMessageViewController, inAppMessageData: InAppMessageData) {
        let activeViewBounds = activeViewController.view.bounds
        
        let width = activeViewBounds.size.width - activeViewBounds.size.width * (CGFloat(inAppMessageData.left) / 100 + CGFloat(inAppMessageData.right) / 100)
        let height = activeViewBounds.size.height - activeViewBounds.size.height * (CGFloat(inAppMessageData.top) / 100 + CGFloat(inAppMessageData.bottom) / 100)
        
        let size = CGSize(width: width, height: height)
        
        let x = (activeViewBounds.size.width - width) / 2
        let y = (activeViewBounds.size.height - height) / 2
        let origin = CGPoint(x: x, y: y)
        
        let inAppMessageSize = CGRect(origin: origin, size: size)
        
        inAppMessageViewController.initWebView(webViewSize: inAppMessageSize)
    }
    
    func getBannerViewController(activeViewController: UIViewController, inAppMessageData: InAppMessageData) -> InAppMessageViewController {
        let inAppMessageViewController = InAppMessageViewController()
        
        inAppMessageViewController.modalPresentationStyle = .overCurrentContext
        inAppMessageViewController.modalTransitionStyle = .crossDissolve
        
        self.prepareBannerInAppMessageSize(activeViewController: activeViewController, inAppMessageViewController: inAppMessageViewController, inAppMessageData: inAppMessageData)
        
        inAppMessageViewController.webView.loadHTMLString(inAppMessageData.html, baseURL: nil)
        
        return inAppMessageViewController
    }
    
    private func prepareBannerInAppMessageSize(activeViewController: UIViewController, inAppMessageViewController: InAppMessageViewController, inAppMessageData: InAppMessageData) {
        let activeViewBounds = activeViewController.view.bounds
        
        let width = activeViewBounds.size.width - activeViewBounds.size.width * (CGFloat(inAppMessageData.left) / 100 + CGFloat(inAppMessageData.right) / 100)
        let height = activeViewBounds.size.height - activeViewBounds.size.height * (CGFloat(inAppMessageData.top) / 100 + CGFloat(inAppMessageData.bottom) / 100)
        
        let size = CGSize(width: width, height: height)
        
        let x = (activeViewBounds.size.width - width) / 2
        let y = (activeViewBounds.size.height - height) / 2
        let origin = CGPoint(x: x, y: y)
        
        let inAppMessageSize = CGRect(origin: origin, size: size)
        
        inAppMessageViewController.initWebView(webViewSize: inAppMessageSize)
    }
}

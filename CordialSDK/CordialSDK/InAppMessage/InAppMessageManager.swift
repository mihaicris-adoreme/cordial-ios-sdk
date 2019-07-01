//
//  InAppMessageManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 6/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class InAppMessageManager {
    
    func getWebViewController(activeViewController: UIViewController, html: String) -> UIViewController {
        let inAppMessageViewController = InAppMessageViewController()
        
        inAppMessageViewController.modalPresentationStyle = .overCurrentContext
        inAppMessageViewController.modalTransitionStyle = .crossDissolve

        self.prepareInAppMessageSize(activeViewController: activeViewController, inAppMessageViewController: inAppMessageViewController)
        
        inAppMessageViewController.webView.loadHTMLString(html, baseURL: nil)
        
        return inAppMessageViewController
    }
    
    private func prepareInAppMessageSize(activeViewController: UIViewController, inAppMessageViewController: InAppMessageViewController) {
        let scale = CGFloat(0.7)
        
        let width = activeViewController.view.bounds.size.width * scale
        let height = activeViewController.view.bounds.size.height * scale
        let size = CGSize(width: width, height: height)
        
        let x = (activeViewController.view.bounds.size.width - width) / 2
        let y = (activeViewController.view.bounds.size.height - height) / 2
        let origin = CGPoint(x: x, y: y)
        
        let inAppMessageSize = CGRect(origin: origin, size: size)
        
        inAppMessageViewController.initWebView(webViewSize: inAppMessageSize)
    }
    
}

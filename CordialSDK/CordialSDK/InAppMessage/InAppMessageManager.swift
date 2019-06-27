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
        
        inAppMessageViewController.view.bounds = activeViewController.view.bounds
        inAppMessageViewController.view.frame = activeViewController.view.frame
        
        inAppMessageViewController.webView.loadHTMLString(html, baseURL: nil)
        
        return inAppMessageViewController
    }
    
}

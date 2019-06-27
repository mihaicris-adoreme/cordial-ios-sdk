//
//  InAppMessageViewController.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 6/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit
import WebKit

class InAppMessageViewController: UIViewController, WKNavigationDelegate {
    
    let webView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.navigationDelegate = self
        
        self.webView.bounds = self.view.bounds
        self.webView.frame = self.view.frame
        
        self.webView.scrollView.isScrollEnabled = false
        
        self.view.addSubview(self.webView)
    }
    
    // MARK: WKNavigationDelegate
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url, let scheme = url.scheme, scheme.contains("cordial") else {
            // This is not HTTP link - can be a local file or a mailto, etc.
            decisionHandler(.allow)
            return
        }
        
        // This is a HTTP link
        UIApplication.shared.open(url, options:[:], completionHandler: nil)
        
        decisionHandler(.allow)
    }
    
}

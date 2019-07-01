//
//  InAppMessageViewController.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 6/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit
import WebKit

class InAppMessageViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.scrollView.delegate = self
        self.webView.scrollView.isScrollEnabled = false
        
        let webView = UIView(frame: self.webView.frame)
        webView.addSubview(self.webView)
        self.view = webView
    }
    
    func initWebView(webViewSize: CGRect) {
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        let js = "function test() { window.location.href='https://tjs.cordialdev.com/prep-tj1.html'; }"
        let userScript = WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
        webConfiguration.userContentController = contentController
        
        self.webView = WKWebView(frame: webViewSize, configuration: webConfiguration)
    }
    
    // MARK: WKNavigationDelegate
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var navigationActionPolicy = WKNavigationActionPolicy.cancel
        
        if let url = navigationAction.request.url {
            if let scheme = url.scheme, scheme.contains("http") {
                let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                userActivity.webpageURL = url
                let _ = UIApplication.shared.delegate?.application?(UIApplication.shared, continue: userActivity, restorationHandler: { _ in })
                
                navigationActionPolicy = .cancel
            } else {
                navigationActionPolicy = .allow
            }
            
            if url.absoluteString == "dismiss" {
                self.dismiss(animated: true, completion: nil)
                navigationActionPolicy = .cancel
            }
        }
        
        decisionHandler(navigationActionPolicy)
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
        scrollView.panGestureRecognizer.isEnabled = false
    }

}

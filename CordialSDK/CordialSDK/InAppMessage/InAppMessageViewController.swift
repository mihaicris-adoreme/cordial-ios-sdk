//
//  InAppMessageViewController.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 6/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit
import WebKit

class InAppMessageViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, UIScrollViewDelegate {
    
    var webView: WKWebView!
    
    let inAppMessageProcess = InAppMessageProcess()
    
    override func loadView() {
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.scrollView.delegate = self
        self.webView.scrollView.isScrollEnabled = false
        
        let webView = UIView(frame: self.webView.frame)
        webView.addSubview(self.webView)
        self.view = webView
        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
    }
    
    func initWebView(webViewSize: CGRect) {
        let webConfiguration = WKWebViewConfiguration()
        
        if let inAppMessageJS = inAppMessageProcess.getInAppMessageJS() {
            let userScript = WKUserScript(source: inAppMessageJS, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
            
            let contentController = WKUserContentController()
            contentController.addUserScript(userScript)
            contentController.add(self, name: "buttonAction")
            webConfiguration.userContentController = contentController
        }

        self.webView = WKWebView(frame: webViewSize, configuration: webConfiguration)
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
        scrollView.panGestureRecognizer.isEnabled = false
    }

    // MARK: WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "buttonAction" {
            if let dict = message.body as? NSDictionary {
                if let deepLink = dict["deepLink"] as? String, let url = URL(string: deepLink) {
                    inAppMessageProcess.openDeepLink(url: url)
                }
                
                if let eventName = dict["eventName"] as? String {
                    inAppMessageProcess.sendCustomEvent(eventName: eventName)
                }
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}

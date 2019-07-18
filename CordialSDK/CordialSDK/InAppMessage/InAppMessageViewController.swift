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
    var inAppMessageView: UIView!
    var isBanner: Bool!
    
    let inAppMessageProcess = InAppMessageProcess()
    
    var zoomScale = CGFloat()
    
    override func loadView() {
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.scrollView.delegate = self
        self.webView.scrollView.isScrollEnabled = false
        
        self.inAppMessageView.addSubview(self.webView)
        self.view = inAppMessageView
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
    
        if self.isBanner {
            self.inAppMessageView = InAppMessageBannerView(frame: self.webView.frame)
        } else {
            self.inAppMessageView = UIView(frame: self.webView.frame)
            self.inAppMessageView.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        }

    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
        scrollView.panGestureRecognizer.isEnabled = false
        self.zoomScale = scrollView.zoomScale
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.setZoomScale(zoomScale, animated: false)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.setZoomScale(zoomScale, animated: false)
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
            
            if self.isBanner {
                UIView.animate(withDuration: inAppMessageProcess.bannerAnimationDuration, animations: {
                    let y = self.view.frame.origin.y + self.view.frame.size.height
                    self.view.frame = CGRect(x: self.view.frame.origin.x, y: -y, width: self.view.frame.size.width, height: self.view.frame.size.height)
                }, completion: { result in
                    if result {
                        self.view.removeFromSuperview()
                    }
                })
            } else {
                self.view.removeFromSuperview()
            }
        }
    }
}

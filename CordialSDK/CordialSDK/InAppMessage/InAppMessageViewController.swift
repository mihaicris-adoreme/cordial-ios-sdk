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
    var inAppMessageData: InAppMessageData!
    
    let cordialAPI = CordialAPI()
    let internalCordialAPI = InternalCordialAPI()
    
    var zoomScale = CGFloat()
    var isBannerAvailable = false
    
    override func loadView() {
        self.webView.loadHTMLString(self.inAppMessageData.html, baseURL: nil)
        
        self.inAppMessageView.addSubview(self.webView)
        self.view = inAppMessageView
        
        if self.isBanner {
            self.isBannerAvailable = true
            self.addInAppMessageBannerGesturesRecognizer()
            self.removeInAppMessageBannerWithDelay()
        }
    }
    
    func removeInAppMessageBannerWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0, execute: {
            if self.isBannerAvailable {
                self.removeBannerFromSuperviewWithAnimation(eventName: API.EVENT_NAME_AUTO_REMOVE_IN_APP_MESSAGE)
            }
        })
    }
    
    func addInAppMessageBannerGesturesRecognizer(){
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpGestureRecognizer))
        swipeUpGesture.direction = .up
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownGestureRecognizer))
        swipeDownGesture.direction = .down
        
        self.view.addGestureRecognizer(swipeUpGesture)
        self.view.addGestureRecognizer(swipeDownGesture)
    }
    
    @objc func swipeUpGestureRecognizer() {
        if self.inAppMessageData.type == InAppMessageType.banner_up {
            self.removeBannerFromSuperviewWithAnimation(eventName: API.EVENT_NAME_MANUAL_REMOVE_IN_APP_MESSAGE)
        }
    }
    
    @objc func swipeDownGestureRecognizer() {
        if self.inAppMessageData.type == InAppMessageType.banner_bottom {
            self.removeBannerFromSuperviewWithAnimation(eventName: API.EVENT_NAME_MANUAL_REMOVE_IN_APP_MESSAGE)
        }
    }
    
    func initWebView(webViewSize: CGRect, mcID: String) {
        let webConfiguration = WKWebViewConfiguration()
        
        if let inAppMessageJS = InAppMessageProcess.shared.getInAppMessageJS() {
            let contentController = WKUserContentController()
            
            let staticUserScript = WKUserScript(source: inAppMessageJS, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            contentController.addUserScript(staticUserScript)
            
            let dynamicUserScript = self.getDynamicUserScript(mcID: mcID)
            contentController.addUserScript(dynamicUserScript)
            
            contentController.add(self, name: "action")
            
            webConfiguration.userContentController = contentController
        }

        self.webView = WKWebView(frame: webViewSize, configuration: webConfiguration)
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.scrollView.delegate = self
        self.webView.scrollView.isScrollEnabled = false
        self.webView.allowsLinkPreview = false
    
        if self.isBanner {
            self.inAppMessageView = InAppMessageBannerView(frame: self.webView.frame)
        } else {
            self.inAppMessageView = UIView(frame: self.webView.frame)
            self.inAppMessageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissModalInAppMessage)))
        }

    }
    
    func getDynamicUserScript(mcID: String) -> WKUserScript {
        let script = """
                     function action(deepLink = null, eventName = null, mcID = "\(mcID)") {
                        try {
                            webkit.messageHandlers.action.postMessage({
                                mcID: mcID,
                                deepLink: deepLink,
                                eventName: eventName
                            });
                        } catch (error) {
                            console.error(error);
                        }
                     }
                     """
        
        return WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    }
    
    func removeBannerFromSuperviewWithAnimation(eventName: String?) {
        UIView.animate(withDuration: InAppMessageProcess.shared.bannerAnimationDuration, animations: {
            switch self.inAppMessageData.type {
            case InAppMessageType.banner_up:
                let x = self.view.frame.origin.x
                let y = self.view.frame.origin.y + self.view.frame.size.height
                let width = self.view.frame.size.width
                let height = self.view.frame.size.height
                
                self.view.frame = CGRect(x: x, y: -y, width: width, height: height)
            case InAppMessageType.banner_bottom:
                let x = self.view.frame.origin.x
                let y = self.view.frame.origin.y + self.view.frame.size.height
                let width = self.view.frame.size.width
                let height = self.view.frame.size.height
                
                self.view.frame = CGRect(x: x, y: y, width: width, height: height)
            default: break
            }
            
        }, completion: { result in
            self.isBannerAvailable = false
            
            if let eventName = eventName {
                let mcID = self.inAppMessageData.mcID
                let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: nil)
                self.internalCordialAPI.sendSystemEvent(sendCustomEventRequest: sendCustomEventRequest)
            }
            
            self.removeModalFromSuperviewWithoutAnimation()
        })
    }
    
    @objc func dismissModalInAppMessage() {
        let mcID = self.inAppMessageData.mcID
        let sendCustomEventRequest = SendCustomEventRequest(eventName: API.EVENT_NAME_MANUAL_REMOVE_IN_APP_MESSAGE, mcID: mcID, properties: nil)
        self.internalCordialAPI.sendSystemEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        self.removeModalFromSuperviewWithoutAnimation()
    }
    
    func removeModalFromSuperviewWithoutAnimation() {
        InAppMessageProcess.shared.isPresentedInAppMessage = false
        self.view.removeFromSuperview()
        
        let mcID = self.inAppMessageData.mcID
        InAppMessageProcess.shared.deleteInAppMessageFromCoreDataByMcID(mcID: mcID)
        
        InAppMessageProcess.shared.showDisplayImmediatelyInAppMessageIfExistAndAvailable()
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
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
        if message.name == "action" {
            if let dict = message.body as? NSDictionary {
                if let mcID = dict["mcID"] as? String, let deepLink = dict["deepLink"] as? String, let url = URL(string: deepLink) {
                    self.internalCordialAPI.setCurrentMcID(mcID: mcID)
                    self.internalCordialAPI.openDeepLink(url: url)
                }
                
                if let mcID = dict["mcID"] as? String, let eventName = dict["eventName"] as? String {
                    let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: nil)
                    self.internalCordialAPI.sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
                }
            }
            
            if self.isBanner {
                self.removeBannerFromSuperviewWithAnimation(eventName: nil)
            } else {
                self.removeModalFromSuperviewWithoutAnimation()
            }
        }
    }
}

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
    
    var bannerCenterY = CGFloat(0)
    
    override func loadView() {
        self.webView.loadHTMLString(self.inAppMessageData.html, baseURL: nil)
        
        self.inAppMessageView.addSubview(self.webView)
        self.view = inAppMessageView
        
        if self.isBanner {
            self.isBannerAvailable = true
            self.bannerCenterY = self.view.center.y
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
    
    func addInAppMessageBannerGesturesRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedBannerView(_:)))
        self.webView.addGestureRecognizer(panGesture)
    }
    
    @objc func draggedBannerView(_ sender: UIPanGestureRecognizer) {
        let yVelocity = sender.velocity(in: self.webView).y
        let translation = sender.translation(in: self.webView)
        
        if abs(yVelocity) < 1200 {
            let y = self.webView.center.y + translation.y
            
            switch self.inAppMessageData.type {
            case InAppMessageType.banner_up:
                if self.bannerCenterY > y {
                    self.webView.bringSubviewToFront(self.webView)
                    self.webView.center = CGPoint(x: self.webView.center.x, y: y)
                    sender.setTranslation(CGPoint.zero, in: self.webView)
                }
            case InAppMessageType.banner_bottom:
                if self.bannerCenterY < y {
                    self.webView.bringSubviewToFront(self.webView)
                    self.webView.center = CGPoint(x: self.webView.center.x, y: y)
                    sender.setTranslation(CGPoint.zero, in: self.webView)
                }
            default:
                break
            }
        } else if sender.state == .ended {
            switch self.inAppMessageData.type {
            case InAppMessageType.banner_up:
                if Int(yVelocity).signum() == -1 {
                    self.removeBannerFromSuperviewWithAnimation(eventName: API.EVENT_NAME_MANUAL_REMOVE_IN_APP_MESSAGE)
                }
            case InAppMessageType.banner_bottom:
                if Int(yVelocity).signum() == 1 {
                    self.removeBannerFromSuperviewWithAnimation(eventName: API.EVENT_NAME_MANUAL_REMOVE_IN_APP_MESSAGE)
                }
            default:
                break
            }
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
            let x = self.webView.frame.origin.x
            var y = self.webView.frame.origin.y + self.webView.frame.size.height
            
            if #available(iOS 11.0, *), let safeAreaInsetsTop = UIApplication.shared.keyWindow?.safeAreaInsets.top, let safeAreaInsetsBottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
                y += safeAreaInsetsTop
                y += safeAreaInsetsBottom
            }
            
            let width = self.webView.frame.size.width
            let height = self.webView.frame.size.height
            
            switch self.inAppMessageData.type {
            case InAppMessageType.banner_up:
                self.webView.frame = CGRect(x: x, y: -y, width: width, height: height)
            case InAppMessageType.banner_bottom:
                self.webView.frame = CGRect(x: x, y: y, width: width, height: height)
            default: break
            }
            
        }, completion: { result in
            self.isBannerAvailable = false
            
            if let eventName = eventName {
                let mcID = self.cordialAPI.getCurrentMcID()
                let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: nil)
                self.internalCordialAPI.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
            }
            
            InAppMessageProcess.shared.isPresentedInAppMessage = false
            self.view.removeFromSuperview()
            InAppMessageProcess.shared.showDisplayImmediatelyInAppMessageIfExistAndAvailable()
        })
    }
    
    @objc func dismissModalInAppMessage() {
        let mcID = self.cordialAPI.getCurrentMcID()
        let sendCustomEventRequest = SendCustomEventRequest(eventName: API.EVENT_NAME_MANUAL_REMOVE_IN_APP_MESSAGE, mcID: mcID, properties: nil)
        self.internalCordialAPI.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        self.removeModalFromSuperviewWithoutAnimation()
    }
    
    func removeModalFromSuperviewWithoutAnimation() {
        InAppMessageProcess.shared.isPresentedInAppMessage = false
        self.view.removeFromSuperview()
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
                
                if let eventName = dict["eventName"] as? String {
                    let mcID = self.cordialAPI.getCurrentMcID()
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

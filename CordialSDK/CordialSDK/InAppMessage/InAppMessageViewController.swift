//
//  InAppMessageViewController.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 6/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit
import WebKit
import os.log

class InAppMessageViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, UIScrollViewDelegate {
    
    var webView: WKWebView!
    var inAppMessageView: UIView!
    var isBanner: Bool!
    var inAppMessageData: InAppMessageData!
    
    let cordialAPI = CordialAPI()
    let internalCordialAPI = InternalCordialAPI()
    
    let webConfiguration = WKWebViewConfiguration()
    let contentController = WKUserContentController()
    
    var zoomScale = CGFloat()
    var isBannerAvailable = false
    
    var bannerCenterY = CGFloat()
    var prevBannerCenterY = CGFloat()
    var isBannerRemovingWithAnimation = false
    
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
                self.removeBannerFromSuperviewWithAnimation(eventName: API.EVENT_NAME_AUTO_REMOVE_IN_APP_MESSAGE, duration: InAppMessageProcess.shared.bannerAnimationDuration)
            }
        })
    }
    
    func addInAppMessageBannerGesturesRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedBannerView(_:)))
        self.webView.addGestureRecognizer(panGesture)
    }
    
    @objc func draggedBannerView(_ sender: UIPanGestureRecognizer) {
        if !self.isBannerRemovingWithAnimation {
            self.prevBannerCenterY = self.webView.center.y
            
            let yVelocity = sender.velocity(in: self.webView).y
            let translation = sender.translation(in: self.webView)
            
            let offset = abs(self.prevBannerCenterY - self.bannerCenterY)
            let duration = TimeInterval(offset / self.webView.frame.height)
                    
            let y = self.webView.center.y + translation.y
            
            let swipeVelocity = CGFloat(1000)
            
            if abs(yVelocity) < swipeVelocity {
                if sender.state == .ended {
                    if offset > self.webView.frame.height / 2 {
                        self.removeBannerFromSuperviewWithAnimation(eventName: API.EVENT_NAME_MANUAL_REMOVE_IN_APP_MESSAGE, duration: duration)
                    } else {
                        UIView.animate(withDuration: duration, animations: {
                            self.webView.center = CGPoint(x: self.webView.center.x, y: self.bannerCenterY)
                        })
                    }
                } else if (self.inAppMessageData.type == InAppMessageType.banner_up && self.bannerCenterY < y) || (self.inAppMessageData.type == InAppMessageType.banner_bottom && self.bannerCenterY > y) {
                    UIView.animate(withDuration: duration, animations: {
                        self.webView.center = CGPoint(x: self.webView.center.x, y: self.bannerCenterY)
                    })
                } else if (self.inAppMessageData.type == InAppMessageType.banner_up && self.bannerCenterY > y) || (self.inAppMessageData.type == InAppMessageType.banner_bottom && self.bannerCenterY < y) {
                    self.webView.bringSubviewToFront(self.webView)
                    self.webView.center = CGPoint(x: self.webView.center.x, y: y)
                    sender.setTranslation(CGPoint.zero, in: self.webView)
                }
            } else if sender.state == .ended {
                switch self.inAppMessageData.type {
                case InAppMessageType.banner_up:
                    if Int(yVelocity).signum() == -1 {
                        self.removeBannerFromSuperviewWithAnimation(eventName: API.EVENT_NAME_MANUAL_REMOVE_IN_APP_MESSAGE, duration: InAppMessageProcess.shared.bannerAnimationDuration)
                    }
                case InAppMessageType.banner_bottom:
                    if Int(yVelocity).signum() == 1 {
                        self.removeBannerFromSuperviewWithAnimation(eventName: API.EVENT_NAME_MANUAL_REMOVE_IN_APP_MESSAGE, duration: InAppMessageProcess.shared.bannerAnimationDuration)
                    }
                default:
                    break
                }
            }
        }
    }
    
    func initWebView(webViewSize: CGRect, inAppMessageData: InAppMessageData) {
        self.inAppMessageData = inAppMessageData
        
        if let inAppMessageJS = InAppMessageProcess.shared.getInAppMessageJS() {
            let staticUserScript = WKUserScript(source: inAppMessageJS, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            self.contentController.addUserScript(staticUserScript)
            
            self.contentController.add(self, name: "action")
            
            self.webConfiguration.userContentController = self.contentController
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("IAM: contentController added to webConfiguration successfully", log: OSLog.cordialError, type: .info)
            }
        }

        self.webView = WKWebView(frame: webViewSize, configuration: self.webConfiguration)
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
    
    func removeBannerFromSuperviewWithAnimation(eventName: String?, duration: TimeInterval) {
        self.isBannerRemovingWithAnimation = true
        
        UIView.animate(withDuration: duration, animations: {
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
                let mcID = self.inAppMessageData.mcID
                let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
                self.internalCordialAPI.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
            }
            
            self.removeInAppMessageFromSuperview()
        })
    }
    
    @objc func dismissModalInAppMessage() {
        let mcID = self.inAppMessageData.mcID
        let sendCustomEventRequest = SendCustomEventRequest(eventName: API.EVENT_NAME_MANUAL_REMOVE_IN_APP_MESSAGE, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
        self.internalCordialAPI.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        self.removeInAppMessageFromSuperview()
    }
    
    func removeInAppMessageFromSuperview() {
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
                if let deepLink = dict["deepLink"] as? String, let url = URL(string: deepLink) {
                    let mcID = self.inAppMessageData.mcID
                    self.internalCordialAPI.setCurrentMcID(mcID: mcID)
                    self.internalCordialAPI.openDeepLink(url: url)
                }
                
                if let eventName = dict["eventName"] as? String {
                    let mcID = self.inAppMessageData.mcID
                    let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: nil)
                    self.internalCordialAPI.sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
                }
            }
            
            if self.isBanner {
                self.removeBannerFromSuperviewWithAnimation(eventName: nil, duration: InAppMessageProcess.shared.bannerAnimationDuration)
            } else {
                self.removeInAppMessageFromSuperview()
            }
        }
    }
}

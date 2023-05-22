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
    
    var bannerCenterY = CGFloat()
    var prevBannerCenterY = CGFloat()
    var isBannerRemovingWithAnimation = false
    
    override func loadView() {
        self.webView.loadHTMLString(self.inAppMessageData.html, baseURL: URL(string: API.IAM_WEB_VIEW_BASE_URL))
        
        self.inAppMessageView.addSubview(self.webView)
        self.view = inAppMessageView
        
        if self.isBanner {
            self.isBannerAvailable = true
            self.addInAppMessageBannerGesturesRecognizer()
            self.removeInAppMessageBannerWithDelay()
        }
    }
    
    func removeInAppMessageBannerWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: {
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
                    self.webView.superview?.bringSubviewToFront(self.webView)
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
    
    func initWebView(inAppMessageData: InAppMessageData) {
        self.inAppMessageData = inAppMessageData
        
        let webConfiguration = WKWebViewConfiguration()
        
        if let inAppMessageJS = InAppMessageProcess.shared.getInAppMessageJS() {
            let contentController = WKUserContentController()
            
            let staticUserScript = WKUserScript(source: inAppMessageJS, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            contentController.addUserScript(staticUserScript)
            
            contentController.add(self, name: "crdlAction")
            contentController.add(self, name: "crdlCaptureAllInputs")
            contentController.add(self, name: "determineContentHeightInternalAction")
            
            webConfiguration.userContentController = contentController
            
            LoggerManager.shared.info(message: "IAM Info: [contentController added to webConfiguration successfully]", category: "CordialSDKInAppMessage")
        }

        let webFrame = CGRect(x: 0, y: 0, width: self.getInAppMessageWidth(), height: 0)
        
        self.webView = WKWebView(frame: webFrame, configuration: webConfiguration)
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
            var y = self.webView.center.y + self.webView.frame.size.height
            
            if let safeAreaInsetsTop = UIApplication.shared.keyWindow?.safeAreaInsets.top,
               let safeAreaInsetsBottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
                
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
    
    func removeInAppMessage() {
        if self.isBanner {
            self.removeBannerFromSuperviewWithAnimation(eventName: nil, duration: InAppMessageProcess.shared.bannerAnimationDuration)
        } else {
            self.removeInAppMessageFromSuperview()
        }
    }
    
    private func addSafeAreaTopMarginToModalInAppMessage() {
        let safeAreaTopMargin = self.getSafeAreaTopMargin()
        let screenBounds = UIScreen.main.bounds
        
        if self.webView.frame.height > screenBounds.size.height - safeAreaTopMargin {
            self.view.frame.origin.y = safeAreaTopMargin
            self.view.frame.size.height -= safeAreaTopMargin
        }
    }
    
    private func getSafeAreaTopMargin() -> CGFloat {
        return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
    }
    
    private func getInAppMessageWidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.size.width
        let marginLeft = CGFloat(self.inAppMessageData.left) / 100
        let marginRight = CGFloat(self.inAppMessageData.right) / 100
        
        return screenWidth - screenWidth * (marginLeft + marginRight)
    }
    
    // MARK: WKNavigationDelegate
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if url.absoluteString == API.IAM_WEB_VIEW_BASE_URL {
            decisionHandler(.allow)
        } else {
            let mcID = self.inAppMessageData.mcID
            
            self.cordialAPI.setCurrentMcID(mcID: mcID)
            CordialVanityDeepLink().open(url: url)
            
            self.removeInAppMessage()
            
            decisionHandler(.cancel)
        }
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
        switch message.name {
        case "crdlAction":
            self.userClickedAnyInAppMessageButton(messageBody: message.body)
        case "crdlCaptureAllInputs":
            self.userClickedAnyInAppMessageButton(messageBody: message.body)
        case "determineContentHeightInternalAction":
            self.determineContentHeightInternalAction(messageBody: message.body)
        default: break
        }
    }
    
    func userClickedAnyInAppMessageButton(messageBody: Any) {
        if let dict = messageBody as? NSDictionary {
            let mcID = self.inAppMessageData.mcID
            
            if let deepLink = dict["deepLink"] as? String, let url = URL(string: deepLink) {
                self.cordialAPI.setCurrentMcID(mcID: mcID)
                CordialVanityDeepLink().open(url: url)
            }
            
            if let eventName = dict["eventName"] as? String {
                self.cordialAPI.setCurrentMcID(mcID: mcID)
                
                if let inputsMapping = dict["inputsMapping"] as? [String: Any] {
                    
                    var properties = [String: Any]()
                    inputsMapping.forEach { (key: String, value: Any) in
                        if let boxValue = value as? ObjCBoxable,
                           let value = JSONStructure().box(boxValue)?.value {
                            properties[key] = value
                        }
                    }
                    
                    // UIKit
                    if let inAppMessageInputsDelegate = CordialApiConfiguration.shared.inAppMessageInputsDelegate {
                        inAppMessageInputsDelegate.inputsCaptured(eventName: eventName, properties: properties)
                    }
                    
                    // SwiftUI
                    if #available(iOS 13.0, *) {
                        DispatchQueue.main.async {
                            CordialSwiftUIInAppMessagePublisher.shared.publishInputsCaptured(eventName: eventName, properties: properties)
                        }
                    }
                    
                    let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: properties)
                    self.internalCordialAPI.sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
                } else {
                    let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: nil)
                    self.internalCordialAPI.sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
                }
            }
        }
        
        self.removeInAppMessage()
    }
    
    func determineContentHeightInternalAction(messageBody: Any) {
        if let dict = messageBody as? NSDictionary,
           var height = dict["height"] as? CGFloat {
            
            let width = self.getInAppMessageWidth()
            
            let screenBounds = UIScreen.main.bounds
            
            let minimumHeight = screenBounds.size.height * 0.15
            if height < minimumHeight {
                height = minimumHeight
            }
            
            if self.isBanner {
                let x = (screenBounds.size.width - width) / 2
                
                let maximumHeight = screenBounds.size.height - screenBounds.size.height * (5 / 100 + 5 / 100)
                if height > maximumHeight {
                    height = maximumHeight
                }
                
                var y = CGFloat()
                switch self.inAppMessageData.type {
                case InAppMessageType.banner_up:
                    y = screenBounds.size.height * 5 / 100
                case InAppMessageType.banner_bottom:
                    y = screenBounds.size.height - (screenBounds.size.height * 5 / 100) - height
                default: break
                }
                
                let origin = CGPoint(x: x, y: y)
                
                let size = CGSize(width: width, height: height)
                
                let inAppMessageSize = CGRect(origin: origin, size: size)
                
                self.webView.frame = inAppMessageSize
                
                self.bannerCenterY = self.webView.center.y
            } else {
                let x = (screenBounds.size.width - width) / 2
                
                switch self.inAppMessageData.type {
                case .fullscreen:
                    let safeAreaTopMargin = self.getSafeAreaTopMargin()
                    
                    if height > screenBounds.size.height - safeAreaTopMargin {
                        self.webView.scrollView.isScrollEnabled = true
                        self.webView.scrollView.showsHorizontalScrollIndicator = false
                        self.webView.scrollView.showsVerticalScrollIndicator = false
                    }
                    
                    height = screenBounds.size.height
                default:
                    let maximumHeight = screenBounds.size.height - screenBounds.size.height * (CGFloat(self.inAppMessageData.top) / 100 + CGFloat(self.inAppMessageData.bottom) / 100)
                    if height > maximumHeight {
                        height = maximumHeight
                                                
                        self.webView.scrollView.isScrollEnabled = true
                        self.webView.scrollView.showsHorizontalScrollIndicator = false
                        self.webView.scrollView.showsVerticalScrollIndicator = false
                    }
                }
                
                let y = (screenBounds.size.height - height) / 2
                
                let origin = CGPoint(x: x, y: y)
                                                
                let size = CGSize(width: width, height: height)
                
                let inAppMessageSize = CGRect(origin: origin, size: size)
                
                self.webView.frame = inAppMessageSize
                
                self.addSafeAreaTopMarginToModalInAppMessage()
            }
        }
    }
}

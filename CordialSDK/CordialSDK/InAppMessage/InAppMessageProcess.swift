//
//  InAppMessageProcess.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/2/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class InAppMessageProcess {
    
    let cordialAPI = CordialAPI()
    let internalCordialAPI = InternalCordialAPI()
    
    let bannerAnimationDuration = 1.0
    
    func getInAppMessageJS() -> String? {
        if let resourceBundleURL = Bundle(for: type(of: self)).url(forResource: "InAppMessage", withExtension: "js") {
            do {
                let contents = try String(contentsOfFile: resourceBundleURL.path)
                
                return contents
            } catch {
                return nil
            }
        }
        
        return nil
    }
    
    func openDeepLink(url: URL) {
        if let scheme = url.scheme, scheme.contains("http") {
            let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
            userActivity.webpageURL = url
            let _ = UIApplication.shared.delegate?.application?(UIApplication.shared, continue: userActivity, restorationHandler: { _ in })
        } else {
            UIApplication.shared.open(url, options:[:], completionHandler: nil)
        }
    }
    
    func addAnimationSubviewInAppMessageBanner(inAppMessageData: InAppMessageData, webViewController: InAppMessageViewController, activeViewController: UIViewController) {
        switch inAppMessageData.type {
        case InAppMessageType.banner_up:
            let x = webViewController.view.frame.origin.x
            let y = webViewController.view.frame.origin.y + webViewController.view.frame.size.height
            let width = webViewController.view.frame.size.width
            let height = webViewController.view.frame.size.height
            
            webViewController.view.frame = CGRect(x: x, y: -y, width: width, height: height)
            
            activeViewController.view.addSubview(webViewController.view)
            
            UIView.animate(withDuration: InAppMessageProcess().bannerAnimationDuration, animations: {
                let x = webViewController.view.frame.origin.x
                let y = abs(webViewController.view.frame.origin.y) - webViewController.view.frame.size.height
                let width = webViewController.view.frame.size.width
                let height = webViewController.view.frame.size.height
                
                webViewController.view.frame = CGRect(x: x, y: y, width: width, height: height)
            })
        case InAppMessageType.banner_bottom:
            let x = webViewController.view.frame.origin.x
            let y = activeViewController.view.frame.size.height - webViewController.view.frame.origin.y
            let width = webViewController.view.frame.size.width
            let height = webViewController.view.frame.size.height
            
            webViewController.view.frame = CGRect(x: x, y: y, width: width, height: height)
            
            activeViewController.view.addSubview(webViewController.view)
            
            UIView.animate(withDuration: InAppMessageProcess().bannerAnimationDuration, animations: {
                let x = webViewController.view.frame.origin.x
                let y = abs(webViewController.view.frame.origin.y) - webViewController.view.frame.size.height
                let width = webViewController.view.frame.size.width
                let height = webViewController.view.frame.size.height
                
                webViewController.view.frame = CGRect(x: x, y: y, width: width, height: height)
            })
        default: break
        }
    }
    
    func showModalInAppMessageIfExist() {
        if let inAppMessageData = CoreDataManager.shared.inAppMessagesCache.getInAppMessageDataFromCoreData() {
            if let expirationTime = inAppMessageData.expirationTime {
                if Int(expirationTime.timeIntervalSinceNow).signum() == 1 { // -1 if this value is negative and 1 if positive
                    self.showModalInAppMessage(inAppMessageData: inAppMessageData)
                } else {
                    self.showModalInAppMessageIfExist()
                }
            } else {
                self.showModalInAppMessage(inAppMessageData: inAppMessageData)
            }
        }
    }
    
    func showModalInAppMessage(inAppMessageData: InAppMessageData) {
        DispatchQueue.main.async {
            if let activeViewController = self.internalCordialAPI.getActiveViewController() {
                let webViewController = InAppMessageManager().getModalWebViewController(activeViewController: activeViewController, inAppMessageData: inAppMessageData)
                
                activeViewController.view.addSubview(webViewController.view)
                
                let sendCustomEventRequest = SendCustomEventRequest(eventName: API.EVENT_NAME_IN_APP_MESSAGE_WAS_SHOWN, properties: nil)
                self.cordialAPI.sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
            }
        }
    }
    
    func showBannerInAppMessage(inAppMessageData: InAppMessageData) {
        DispatchQueue.main.async {
            if let activeViewController = self.internalCordialAPI.getActiveViewController() {
                let webViewController = InAppMessageManager().getBannerViewController(activeViewController: activeViewController, inAppMessageData: inAppMessageData)
                
                InAppMessageProcess().addAnimationSubviewInAppMessageBanner(inAppMessageData: inAppMessageData, webViewController: webViewController, activeViewController: activeViewController)
                
                let sendCustomEventRequest = SendCustomEventRequest(eventName: API.EVENT_NAME_IN_APP_MESSAGE_WAS_SHOWN, properties: nil)
                self.cordialAPI.sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
            }
        }
    }
}

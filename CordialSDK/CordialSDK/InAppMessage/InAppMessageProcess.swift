//
//  InAppMessageProcess.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/2/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class InAppMessageProcess {
    
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
    
    func sendCustomEvent(eventName: String) {
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: nil)
        CordialAPI().sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
    }
    
    func addAnimationToBannerInAppMessage(inAppMessageData: InAppMessageData, webViewController: InAppMessageViewController, activeViewController: UIViewController) {
        switch inAppMessageData.type {
        case InAppMessageType.banner_up:
            let y = webViewController.view.frame.origin.y + webViewController.view.frame.size.height
            webViewController.view.frame = CGRect(x: webViewController.view.frame.origin.x, y: -y, width: webViewController.view.frame.size.width, height: webViewController.view.frame.size.height)
            activeViewController.view.addSubview(webViewController.view)
            
            UIView.animate(withDuration: InAppMessageProcess().bannerAnimationDuration, animations: {
                
                let y = abs(webViewController.view.frame.origin.y) - webViewController.view.frame.size.height
                webViewController.view.frame = CGRect(x: webViewController.view.frame.origin.x, y: y, width: webViewController.view.frame.size.width, height: webViewController.view.frame.size.height)
            })
        case InAppMessageType.banner_bottom:
            let y = activeViewController.view.frame.size.height - webViewController.view.frame.origin.y
            webViewController.view.frame = CGRect(x: webViewController.view.frame.origin.x, y: y, width: webViewController.view.frame.size.width, height: webViewController.view.frame.size.height)
            activeViewController.view.addSubview(webViewController.view)
            
            UIView.animate(withDuration: InAppMessageProcess().bannerAnimationDuration, animations: {
                let y = abs(webViewController.view.frame.origin.y) - webViewController.view.frame.size.height
                webViewController.view.frame = CGRect(x: webViewController.view.frame.origin.x, y: y, width: webViewController.view.frame.size.width, height: webViewController.view.frame.size.height)
            })
        default: break
        }
    }
}

//
//  InAppMessageProcess.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/2/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class InAppMessageProcess {
    
    static let shared = InAppMessageProcess()
    
    private init(){}
    
    let cordialAPI = CordialAPI()
    let internalCordialAPI = InternalCordialAPI()
    
    let inAppMessageManager = InAppMessageManager()
    
    var isPresentedInAppMessage = false
    
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
    
    func showInAppMessage(inAppMessageData: InAppMessageData) {
        if !self.isPresentedInAppMessage {
            switch inAppMessageData.type {
            case InAppMessageType.modal:
                self.showModalInAppMessage(inAppMessageData: inAppMessageData)
            case InAppMessageType.fullscreen:
                self.showModalInAppMessage(inAppMessageData: inAppMessageData)
            case InAppMessageType.banner_up:
                self.showBannerInAppMessage(inAppMessageData: inAppMessageData)
            case InAppMessageType.banner_bottom:
                self.showBannerInAppMessage(inAppMessageData: inAppMessageData)
            }
            
            CoreDataManager.shared.inAppMessagesParam.deleteInAppMessageParamsByMcID(mcID: inAppMessageData.mcID)
        } else {
            CoreDataManager.shared.inAppMessagesCache.setInAppMessageDataToCoreData(inAppMessageData: inAppMessageData)
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("IAM already presented. Save %{public}@ IAM with mcID: [%{public}@]", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
            }
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
            
            UIView.animate(withDuration: self.bannerAnimationDuration, animations: {
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
            
            UIView.animate(withDuration: self.bannerAnimationDuration, animations: {
                let x = webViewController.view.frame.origin.x
                let y = abs(webViewController.view.frame.origin.y) - webViewController.view.frame.size.height
                let width = webViewController.view.frame.size.width
                let height = webViewController.view.frame.size.height
                
                webViewController.view.frame = CGRect(x: x, y: y, width: width, height: height)
            })
        default: break
        }
    }
    
    func showInAppMessageIfPopupCanBePresented() {
        if !self.isPresentedInAppMessage {
            self.showInAppMessageIfExistAndAvailable()
        }
    }
    
    func showInAppMessageIfExistAndAvailable() {
        if let inAppMessageData = CoreDataManager.shared.inAppMessagesCache.getLatestInAppMessageDataFromCoreData() {
            if self.isAvailableInAppMessage(inAppMessageData: inAppMessageData) {
                self.showInAppMessage(inAppMessageData: inAppMessageData)
            } else {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Not showing %{public}@ IAM with mcID: [%{public}@]. Reason: [Live time has expired]", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
                }
                
                self.showInAppMessageIfExistAndAvailable()
            }
        }
    }
    
    func showDisplayImmediatelyInAppMessageIfExistAndAvailable() {
        if let inAppMessageData = CoreDataManager.shared.inAppMessagesCache.getDisplayImmediatelyInAppMessageDataFromCoreData() {
            if self.isAvailableInAppMessage(inAppMessageData: inAppMessageData) {
                self.showInAppMessage(inAppMessageData: inAppMessageData)
            } else {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Failed showing %{public}@ IAM with mcID: [%{public}@]. Error: [Live time has expired]", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
                }

                self.showDisplayImmediatelyInAppMessageIfExistAndAvailable()
            }
        }
    }
    
    func isAvailableInAppMessage(inAppMessageData: InAppMessageData) -> Bool {
        if let expirationTime = inAppMessageData.expirationTime {
            if Int(expirationTime.timeIntervalSinceNow).signum() == 1 {
                return true
            } else {
                return false
            }
        }
        
        return true
    }
    
    func showModalInAppMessage(inAppMessageData: InAppMessageData) {
        DispatchQueue.main.async {
            if let activeViewController = self.internalCordialAPI.getActiveViewController() {
                let modalWebViewController = self.inAppMessageManager.getModalWebViewController(activeViewController: activeViewController, inAppMessageData: inAppMessageData)
                
                self.addDismissButtonToModalInAppMessageViewController(modalWebViewController: modalWebViewController)
                
                activeViewController.view.addSubview(modalWebViewController.view)
                
                self.isPresentedInAppMessage = true
                
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Showing %{public}@ IAM modal with mcID: [%{public}@]", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
                }
                
                let sendCustomEventRequest = SendCustomEventRequest(eventName: API.EVENT_NAME_IN_APP_MESSAGE_WAS_SHOWN, properties: nil)
                self.cordialAPI.sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
            }
        }
    }
    
    private func addDismissButtonToModalInAppMessageViewController(modalWebViewController: InAppMessageViewController) {
        var safeAreaTop = CGFloat()
        if #available(iOS 11.0, *) {
            if let safeAreaInsetsTop = UIApplication.shared.keyWindow?.safeAreaInsets.top {
                if UIScreen.main.bounds.height - safeAreaInsetsTop < modalWebViewController.webView.frame.height {
                    safeAreaTop = safeAreaInsetsTop
                }
            }
        } 
        
        let closeButton = UIButton(frame: CGRect(x: modalWebViewController.webView.frame.width - 50, y: safeAreaTop, width: 50, height: 50))
        closeButton.setTitle("✖️", for: .normal)
        
        closeButton.addTarget(modalWebViewController, action: #selector(modalWebViewController.dismissModalInAppMessage), for: .touchUpInside)
        closeButton.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        
        modalWebViewController.webView.addSubview(closeButton)
    }
    
    func showBannerInAppMessage(inAppMessageData: InAppMessageData) {
        DispatchQueue.main.async {
            if let activeViewController = self.internalCordialAPI.getActiveViewController() {
                let bannerWebViewController = self.inAppMessageManager.getBannerViewController(activeViewController: activeViewController, inAppMessageData: inAppMessageData)
                
                self.addAnimationSubviewInAppMessageBanner(inAppMessageData: inAppMessageData, webViewController: bannerWebViewController, activeViewController: activeViewController)
                
                self.isPresentedInAppMessage = true
                
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Showing %{public}@ IAM banner with mcID: [%{public}@]", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
                }
                
                let sendCustomEventRequest = SendCustomEventRequest(eventName: API.EVENT_NAME_IN_APP_MESSAGE_WAS_SHOWN, properties: nil)
                self.cordialAPI.sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
            }
        }
    }
}

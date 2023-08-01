//
//  InAppMessageProcess.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/2/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit

class InAppMessageProcess {
    
    static let shared = InAppMessageProcess()
    
    private init() {}
    
    let cordialAPI = CordialAPI()
    let internalCordialAPI = InternalCordialAPI()
    
    let inAppMessageManager = InAppMessageManager()
    
    var isPresentedInAppMessage = false
    
    let bannerAnimationDuration = 1.0
    
    func getInAppMessageJS() -> String? {
        guard let resourceBundleURL = InternalCordialAPI().getResourceBundleURL(forResource: "InAppMessage", withExtension: "js") else { return nil }

        do {
            let contents = try String(contentsOfFile: resourceBundleURL.path)
            
            return contents
            
        } catch let error {
            LoggerManager.shared.error(message: "IAM Error: [\(error.localizedDescription)]", category: "CordialSDKInAppMessage")
            
            return nil
        }
    }
    
    func showInAppMessage(inAppMessageData: InAppMessageData) {
        if InternalCordialAPI().isUserLogin() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let isInAppMessageRelated = CoreDataManager.shared.inAppMessagesRelated.isInAppMessageRelated(mcID: inAppMessageData.mcID),
                   isInAppMessageRelated {
                    
                    InAppMessageProcess.shared.deleteInAppMessageFromCoreDataByMcID(mcID: inAppMessageData.mcID)
                    
                    LoggerManager.shared.info(message: "IAM with mcID [\(inAppMessageData.mcID)] has been removed", category: "CordialSDKInAppMessage")
                } else {
                    self.showInAppMessageProcess(inAppMessageData: inAppMessageData)
                }
            }
        } else {
            LoggerManager.shared.info(message: "IAM: [User no login]. Save \(inAppMessageData.type.rawValue) IAM with mcID: [\(inAppMessageData.mcID)]", category: "CordialSDKInAppMessage")
        }
    }
    
    private func showInAppMessageProcess(inAppMessageData: InAppMessageData) {
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
        } else {
            LoggerManager.shared.info(message: "IAM already presented. Save \(inAppMessageData.type.rawValue) IAM with mcID: [\(inAppMessageData.mcID)]", category: "CordialSDKInAppMessage")
        }
    }
    
    func deleteInAppMessageFromCoreDataByMcID(mcID: String) {
        CoreDataManager.shared.inAppMessagesCache.removeInAppMessageData(mcID: mcID)
        CoreDataManager.shared.inAppMessagesParam.removeInAppMessageParams(mcID: mcID)
        CoreDataManager.shared.inAppMessagesRelated.deleteInAppMessageRelatedStatusByMcID(mcID: mcID)
        CoreDataManager.shared.inAppMessagesShown.deleteInAppMessageShownStatusByMcID(mcID: mcID)
    }
    
    func addAnimationSubviewInAppMessageBanner(inAppMessageData: InAppMessageData, webViewController: InAppMessageViewController, topViewController: UIViewController) {
        switch inAppMessageData.type {
        case InAppMessageType.banner_up:
            let x = webViewController.view.frame.origin.x
            let y = webViewController.view.frame.origin.y + webViewController.view.frame.size.height
            let width = webViewController.view.frame.size.width
            let height = webViewController.view.frame.size.height
            
            webViewController.view.frame = CGRect(x: x, y: -y, width: width, height: height)
            
            topViewController.view.addSubview(webViewController.view)
            
            UIView.animate(withDuration: self.bannerAnimationDuration, animations: {
                let x = webViewController.view.frame.origin.x
                let y = abs(webViewController.view.frame.origin.y) - webViewController.view.frame.size.height
                let width = webViewController.view.frame.size.width
                let height = webViewController.view.frame.size.height
                
                webViewController.view.frame = CGRect(x: x, y: y, width: width, height: height)
            })
        case InAppMessageType.banner_bottom:
            let x = webViewController.view.frame.origin.x
            let y = topViewController.view.frame.size.height - webViewController.view.frame.origin.y
            let width = webViewController.view.frame.size.width
            let height = webViewController.view.frame.size.height
            
            webViewController.view.frame = CGRect(x: x, y: y, width: width, height: height)
            
            topViewController.view.addSubview(webViewController.view)
            
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
    
    private func showInAppMessageIfExistAndAvailable() {
        if let inAppMessageData = CoreDataManager.shared.inAppMessagesCache.fetchLatestInAppMessageData() {
            if self.isAvailableInAppMessage(inAppMessageData: inAppMessageData) {
                self.showInAppMessage(inAppMessageData: inAppMessageData)
            } else {
                InAppMessageProcess.shared.deleteInAppMessageFromCoreDataByMcID(mcID: inAppMessageData.mcID)
                
                LoggerManager.shared.info(message: "Not showing \(inAppMessageData.type.rawValue) IAM with mcID: [\(inAppMessageData.mcID)]. Reason: [Live time has expired]", category: "CordialSDKInAppMessage")
                
                self.showInAppMessageIfExistAndAvailable()
            }
        }
    }
    
    func showDisplayImmediatelyInAppMessageIfExistAndAvailable() {
        if let inAppMessageData = CoreDataManager.shared.inAppMessagesCache.fetchDisplayImmediatelyInAppMessageData() {
            if self.isAvailableInAppMessage(inAppMessageData: inAppMessageData) {
                self.showInAppMessage(inAppMessageData: inAppMessageData)
            } else {
                InAppMessageProcess.shared.deleteInAppMessageFromCoreDataByMcID(mcID: inAppMessageData.mcID)
                
                LoggerManager.shared.info(message: "Failed showing \(inAppMessageData.type.rawValue) IAM with mcID: [\(inAppMessageData.mcID)]. Error: [Live time has expired]", category: "CordialSDKInAppMessage")

                self.showDisplayImmediatelyInAppMessageIfExistAndAvailable()
            }
        }
    }
    
    func isAvailableInAppMessage(inAppMessageData: InAppMessageData) -> Bool {
        if let expirationTime = inAppMessageData.expirationTime {
            return API.isValidExpirationDate(date: expirationTime)
        }
        
        return true
    }
    
    private func showModalInAppMessage(inAppMessageData: InAppMessageData) {
        if let activeViewController = self.internalCordialAPI.getActiveViewController(),
           let topViewController = self.internalCordialAPI.getTopViewController(of: activeViewController) {
            
            if self.inAppMessageManager.isTopViewControllerCanPresentInAppMessage(topViewController: topViewController) {
                let modalWebViewController = self.inAppMessageManager.getModalWebViewController(topViewController: topViewController, inAppMessageData: inAppMessageData)
                                
                self.addDismissButtonToModalInAppMessageViewController(modalWebViewController: modalWebViewController)
                
                topViewController.view.addSubview(modalWebViewController.view)
                
                self.isPresentedInAppMessage = true
                
                LoggerManager.shared.info(message: "Showing \(inAppMessageData.type.rawValue) IAM modal with mcID: [\(inAppMessageData.mcID)]", category: "CordialSDKInAppMessage")
    
                self.sendSystemEventInAppMessageHasBeenShown(inAppMessageData: inAppMessageData)
            } else {
                LoggerManager.shared.info(message: "Skipped display \(inAppMessageData.type.rawValue) IAM with mcID: [\(inAppMessageData.mcID)]. Showing IAM has been denied by CordialSDK configuration. Saved to display later.", category: "CordialSDKInAppMessage")
            }
        }
    }
    
    private func sendSystemEventInAppMessageHasBeenShown(inAppMessageData: InAppMessageData) {
        let mcID = inAppMessageData.mcID
        if let isInAppMessageHasBeenShown = CoreDataManager.shared.inAppMessagesShown.isInAppMessageHasBeenShown(mcID: mcID),
           !isInAppMessageHasBeenShown {
            
            CoreDataManager.shared.inAppMessagesShown.setShownStatusToInAppMessagesShownCoreData(mcID: mcID)
            
            let sendCustomEventRequest = SendCustomEventRequest(eventName: API.EVENT_NAME_IN_APP_MESSAGE_WAS_SHOWN, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
            self.internalCordialAPI.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        }
    }
        
    private func addDismissButtonToModalInAppMessageViewController(modalWebViewController: InAppMessageViewController) {
        let closeButton = UIButton(frame: CGRect(x: modalWebViewController.webView.frame.width - 50, y: 0, width: 50, height: 50))
        closeButton.setTitle("✖️", for: .normal)
        
        closeButton.addTarget(modalWebViewController, action: #selector(modalWebViewController.dismissModalInAppMessage), for: .touchUpInside)
        closeButton.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        
        modalWebViewController.webView.addSubview(closeButton)
    }
    
    private func showBannerInAppMessage(inAppMessageData: InAppMessageData) {
        if let activeViewController = self.internalCordialAPI.getActiveViewController(),
           let topViewController = self.internalCordialAPI.getTopViewController(of: activeViewController) {
            
            if self.inAppMessageManager.isTopViewControllerCanPresentInAppMessage(topViewController: topViewController) {
                let bannerWebViewController = self.inAppMessageManager.getBannerViewController(topViewController: topViewController, inAppMessageData: inAppMessageData)
                
                self.addAnimationSubviewInAppMessageBanner(inAppMessageData: inAppMessageData, webViewController: bannerWebViewController, topViewController: topViewController)
                
                self.isPresentedInAppMessage = true
                
                LoggerManager.shared.info(message: "Showing \(inAppMessageData.type.rawValue) IAM banner with mcID: [\(inAppMessageData.mcID)]", category: "CordialSDKInAppMessage")
                
                self.sendSystemEventInAppMessageHasBeenShown(inAppMessageData: inAppMessageData)
            } else {
                LoggerManager.shared.info(message: "Skipped display \(inAppMessageData.type.rawValue) IAM with mcID: [\(inAppMessageData.mcID)]. Showing IAM has been denied by CordialSDK configuration. Saved to display later.", category: "CordialSDKInAppMessage")
            }
        }
    }
}

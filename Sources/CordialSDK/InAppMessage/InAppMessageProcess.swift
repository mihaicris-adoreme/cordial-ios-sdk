//
//  InAppMessageProcess.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/2/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit
import os.log

class InAppMessageProcess {
    
    static let shared = InAppMessageProcess()
    
    private init() {}
    
    let cordialAPI = CordialAPI()
    let internalCordialAPI = InternalCordialAPI()
    
    let inAppMessageManager = InAppMessageManager()
    
    var isPresentedInAppMessage = false
    
    let bannerAnimationDuration = 1.0
    
    func getInAppMessageJS() -> String? {
        
        guard let resourceBundle = InternalCordialAPI().getResourceBundle() else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("IAM Error: [Could not get bundle that contains InAppMessage.js file]", log: OSLog.cordialInAppMessage, type: .error)
            }
            
            return nil
        }
        
        guard let resourceBundleURL = resourceBundle.url(forResource: "InAppMessage", withExtension: "js") else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("IAM Error: [Could not get bundle url for file InAppMessage.js", log: OSLog.cordialInAppMessage, type: .error)
            }
            
            return nil
        }
        

        do {
            let contents = try String(contentsOfFile: resourceBundleURL.path)
            
            return contents
            
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("IAM Error: [%{public}@]", log: OSLog.cordialInAppMessage, type: .error, error.localizedDescription)
            }
            return nil
        }
    }
    
    func showInAppMessage(inAppMessageData: InAppMessageData) {
        if InternalCordialAPI().isUserLogin() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let isInAppMessageHasBeenShown = CoreDataManager.shared.inAppMessagesShown.isInAppMessageHasBeenShown(mcID: inAppMessageData.mcID),
                   isInAppMessageHasBeenShown {
                    
                    InAppMessageProcess.shared.deleteInAppMessageFromCoreDataByMcID(mcID: inAppMessageData.mcID)
                    
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                        os_log("IAM with mcID [%{public}@] has been removed.", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.mcID)
                    }
                } else {
                    self.showInAppMessageProcess(inAppMessageData: inAppMessageData)
                }
            }
        } else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("IAM: [User no login]. Save %{public}@ IAM with mcID: [%{public}@]", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
            }
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
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("IAM already presented. Save %{public}@ IAM with mcID: [%{public}@]", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
            }
        }
    }
    
    func deleteInAppMessageFromCoreDataByMcID(mcID: String) {
        CoreDataManager.shared.inAppMessagesCache.deleteInAppMessageDataByMcID(mcID: mcID)
        CoreDataManager.shared.inAppMessagesParam.deleteInAppMessageParamsByMcID(mcID: mcID)
        CoreDataManager.shared.inAppMessagesShown.deleteInAppMessagesShownStatusByMcID(mcID: mcID)
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
                InAppMessageProcess.shared.deleteInAppMessageFromCoreDataByMcID(mcID: inAppMessageData.mcID)
                
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
                InAppMessageProcess.shared.deleteInAppMessageFromCoreDataByMcID(mcID: inAppMessageData.mcID)
                
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Failed showing %{public}@ IAM with mcID: [%{public}@]. Error: [Live time has expired]", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
                }

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
    
    func showModalInAppMessage(inAppMessageData: InAppMessageData) {
        if let activeViewController = self.internalCordialAPI.getActiveViewController() {
            if self.inAppMessageManager.isActiveViewControllerCanPresentInAppMessage(activeViewController: activeViewController) {
                let modalWebViewController = self.inAppMessageManager.getModalWebViewController(activeViewController: activeViewController, inAppMessageData: inAppMessageData)
                                
                self.addDismissButtonToModalInAppMessageViewController(modalWebViewController: modalWebViewController)
                
                activeViewController.view.addSubview(modalWebViewController.view)
                
                self.isPresentedInAppMessage = true
                
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Showing %{public}@ IAM modal with mcID: [%{public}@]", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
                }
    
                self.sendSystemEventInAppMessageHasBeenShown(inAppMessageData: inAppMessageData)
            } else {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Skipped display %{public}@ IAM with mcID: [%{public}@]. Showing IAM has been denied by CordialSDK configuration. Saved to display later.", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
                }
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
    
    func showBannerInAppMessage(inAppMessageData: InAppMessageData) {
        if let activeViewController = self.internalCordialAPI.getActiveViewController() {
            if self.inAppMessageManager.isActiveViewControllerCanPresentInAppMessage(activeViewController: activeViewController) {
                let bannerWebViewController = self.inAppMessageManager.getBannerViewController(activeViewController: activeViewController, inAppMessageData: inAppMessageData)
                
                self.addAnimationSubviewInAppMessageBanner(inAppMessageData: inAppMessageData, webViewController: bannerWebViewController, activeViewController: activeViewController)
                
                self.isPresentedInAppMessage = true
                
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Showing %{public}@ IAM banner with mcID: [%{public}@]", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
                }
                
                self.sendSystemEventInAppMessageHasBeenShown(inAppMessageData: inAppMessageData)
            } else {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Skipped display %{public}@ IAM with mcID: [%{public}@]. Showing IAM has been denied by CordialSDK configuration. Saved to display later.", log: OSLog.cordialInAppMessage, type: .info, inAppMessageData.type.rawValue, inAppMessageData.mcID)
                }
            }
        }
    }
}

//
//  InternalCordialAPI.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/15/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class InternalCordialAPI {
    
    let cordialAPI = CordialAPI()
    
    // MARK: Get timestamp
    
    func getTimestamp() -> String {
        let date = Date()
        let formatter = ISO8601DateFormatter()
        
        return formatter.string(from: date)
    }
    
    // MARK: Get device identifier
    
    func getDeviceIdentifier() -> String {
        return UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID)!
    }
    
    // MARK: Send cache from CoreData
    
    func sendCacheFromCoreData() {
        if cordialAPI.getContactPrimaryKey() != nil {
            let customEventRequests = CoreDataManager.shared.customEventRequests.fetchCustomEventRequestsFromCoreData()
            if customEventRequests.count > 0 {
                CustomEventsSender().sendCustomEvents(sendCustomEventRequests: customEventRequests)
            }
            
            if let upsertContactCartRequest = CoreDataManager.shared.contactCartRequest.getContactCartRequestFromCoreData() {
                ContactCartSender().upsertContactCart(upsertContactCartRequest: upsertContactCartRequest)
            }
            
            let sendContactOrderRequests = CoreDataManager.shared.contactOrderRequests.getContactOrderRequestsFromCoreData()
            if sendContactOrderRequests.count > 0 {
                ContactOrdersSender().sendContactOrders(sendContactOrderRequests: sendContactOrderRequests)
            }
        }
        
        let upsertContactRequests = CoreDataManager.shared.contactRequests.getContactRequestsFromCoreData()
        if upsertContactRequests.count > 0 {
            ContactsSender().upsertContacts(upsertContactRequests: upsertContactRequests)
        }
        
        if let sendContactLogoutRequest = CoreDataManager.shared.contactLogoutRequest.getContactLogoutRequestFromCoreData() {
            ContactLogoutSender().sendContactLogout(sendContactLogoutRequest: sendContactLogoutRequest)
        }
        
        InAppMessagesQueueManager().fetchInAppMessagesFromQueue()
    }
    
    // MARK: Get active view controller
    
    func getActiveViewController() -> UIViewController? {
        if var currentVC = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedVC = currentVC.presentedViewController {
                if let navVC = (presentedVC as? UINavigationController)?.viewControllers.last {
                    currentVC = navVC
                } else if let tabVC = (presentedVC as? UITabBarController)?.selectedViewController {
                    currentVC = tabVC
                } else {
                    currentVC = presentedVC
                }
            }
            
            return currentVC
        }
        
        return nil
    }
    
    // MARK: Show modal in-app message
    
    func showModalInAppMessage(inAppMessageData: InAppMessageData) {
        DispatchQueue.main.async {
            if let activeViewController = self.getActiveViewController() {
                let webViewController = InAppMessageManager().getModalWebViewController(activeViewController: activeViewController, inAppMessageData: inAppMessageData)
                
                activeViewController.view.addSubview(webViewController.view)
            }
        }
    }
    
    // MARK: Show banner in-app message
    
    func showBannerInAppMessage(inAppMessageData: InAppMessageData) {
        DispatchQueue.main.async {
            if let activeViewController = self.getActiveViewController() {
                let webViewController = InAppMessageManager().getBannerViewController(activeViewController: activeViewController, inAppMessageData: inAppMessageData)
                
                InAppMessageProcess().addAnimationSubviewInAppMessageBanner(inAppMessageData: inAppMessageData, webViewController: webViewController, activeViewController: activeViewController)
            }
        }
    }

}

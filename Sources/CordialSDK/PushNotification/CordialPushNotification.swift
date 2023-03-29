//
//  CordialPushNotification.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/2/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import UserNotifications
import UserNotificationsUI
import os.log

class CordialPushNotification: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = CordialPushNotification()
    
    private override init() {}
    
    let pushNotificationHelper = PushNotificationHelper()
    
    var isScreenPushNotificationCategoriesShown = false

    func registerForPushNotifications(options: UNAuthorizationOptions) {
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func providesAppNotificationSettings(options: UNAuthorizationOptions, isEducational: Bool) {
        let current = UNUserNotificationCenter.current()
        
        current.getNotificationSettings { settings in
            if isEducational && settings.authorizationStatus != .authorized && settings.authorizationStatus != .provisional {
                PushNotificationCategoriesHandler.shared.openEducationalPushNotificationCategories(options: options)
            } else {
                self.registerForPushNotifications(options: options)
            }
        }
    }
    
    func registerForSilentPushNotifications() {
        DispatchQueue.main.async {
            self.registerRichPushNotificationsActions()
            
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func setupPushNotifications() {
        if CordialApiConfiguration.shared.pushesConfiguration == .SDK {
            UNUserNotificationCenter.current().delegate = self
        }
    }
    
    private func registerRichPushNotificationsActions() {
        let categoryIdentifier = "carouselNotificationCategory"
        if #available(iOS 15.0, *) {
            let carouselNext = UNNotificationAction(identifier: "\(categoryIdentifier).next", title: "Next", options: [], icon: UNNotificationActionIcon(systemImageName: "forward"))
            let carouselPrevious = UNNotificationAction(identifier: "\(categoryIdentifier).previous", title: "Previous", options: [], icon: UNNotificationActionIcon(systemImageName: "backward"))
            let carouselCategory = UNNotificationCategory(identifier: categoryIdentifier, actions: [carouselNext, carouselPrevious], intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([carouselCategory])
        } else {
            let carouselNext = UNNotificationAction(identifier: "\(categoryIdentifier).next", title: "Next", options: [])
            let carouselPrevious = UNNotificationAction(identifier: "\(categoryIdentifier).previous", title: "Previous", options: [])
            let carouselCategory = UNNotificationCategory(identifier: categoryIdentifier, actions: [carouselNext, carouselPrevious], intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([carouselCategory])
        }
    }
    
    // MARK: UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Called when user made a notification tap.
        let userInfo = response.notification.request.content.userInfo
                
        self.pushNotificationHelper.pushNotificationHasBeenTapped(userInfo: userInfo, completionHandler: completionHandler)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Called when notification is delivered to a foreground app.
        let userInfo = notification.request.content.userInfo
        
        self.pushNotificationHelper.pushNotificationHasBeenForegroundDelivered(userInfo: userInfo, completionHandler: completionHandler)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        if CordialApiConfiguration.shared.pushNotificationCategoriesConfiguration == .SDK {
            PushNotificationCategoriesHandler.shared.openPushNotificationCategories()
        } else {
            // UIKit
            if let pushNotificationCategoriesDelegate = CordialApiConfiguration.shared.pushNotificationCategoriesDelegate {
                DispatchQueue.main.async {
                    pushNotificationCategoriesDelegate.openPushNotificationCategories()
                }
            }
            
            // SwiftUI
            if #available(iOS 13.0, *) {
                DispatchQueue.main.async {
                    CordialSwiftUIPushNotificationCategoriesPublisher.shared.publishOpenPushNotificationCategories()
                }
            }
        }
    }
}

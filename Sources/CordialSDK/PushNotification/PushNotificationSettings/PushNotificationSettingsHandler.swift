//
//  PushNotificationSettingsHandler.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 23.02.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

@objcMembers public class PushNotificationSettingsHandler: NSObject {
    
    public static let shared = PushNotificationSettingsHandler()
    
    private override init() {}
    
    public var navigationBarBackgroundColor = UIColor(red: 26/255, green: 29/255, blue: 35/255, alpha: 1)
    public var navigationBarTitleColor = UIColor(red: 211/255, green: 212/255, blue: 217/255, alpha: 1)
    public var navigationBarXmarkColor = UIColor(red: 211/255, green: 212/255, blue: 217/255, alpha: 1)
    
    public var tableViewBackgroundColor = UIColor(red: 33/255, green: 36/255, blue: 41/255, alpha: 1)
    public var tableViewSectionTitleColor = UIColor(red: 166/255, green: 167/255, blue: 172/255, alpha: 1)
    
    public var tableViewCellBackgroundColor = UIColor(red: 26/255, green: 29/255, blue: 35/255, alpha: 1)
    public var tableViewCellTitleColor = UIColor(red: 232/255, green: 233/255, blue: 238/255, alpha: 1)
    
    public var tableViewCellSwitchOnColor = UIColor.systemGreen
    public var tableViewCellSwitchThumbColor = UIColor.white
    
    public func openPushNotificationSettings() {
        if !CordialPushNotification.shared.isScreenPushNotificationSettingsShown {
            DispatchQueue.main.async {
                if let currentVC = InternalCordialAPI().getActiveViewController() {
                    currentVC.present(PushNotificationSettingsTableViewController(), animated: true)
                }
            }
        }
    }
}

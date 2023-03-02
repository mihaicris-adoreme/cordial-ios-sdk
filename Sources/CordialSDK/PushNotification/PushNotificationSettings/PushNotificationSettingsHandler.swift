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
    
    internal var navigationBarBackgroundColor = UIColor(red: 26/255, green: 29/255, blue: 35/255, alpha: 1)
    internal var navigationBarTitleColor = UIColor(red: 211/255, green: 212/255, blue: 217/255, alpha: 1)
    internal var navigationBarXmarkColor = UIColor(red: 211/255, green: 212/255, blue: 217/255, alpha: 1)
    
    internal var tableViewBackgroundColor = UIColor(red: 33/255, green: 36/255, blue: 41/255, alpha: 1)
    internal var tableViewSectionTitleColor = UIColor(red: 166/255, green: 167/255, blue: 172/255, alpha: 1)
    
    internal var tableViewSectionCellBackgroundColor = UIColor(red: 26/255, green: 29/255, blue: 35/255, alpha: 1)
    internal var tableViewSectionCellTitleColor = UIColor(red: 232/255, green: 233/255, blue: 238/255, alpha: 1)
    
    internal var tableViewSectionCellSwitchOnTintColor = UIColor.systemGreen
    internal var tableViewSectionCellSwitchThumbTintColor = UIColor.white
    
    private func setNavigationBarBackgroundColor(_ color: UIColor) {
        self.navigationBarBackgroundColor = color
    }
    
    private func setNavigationBarTitleColor(_ color: UIColor) {
        self.navigationBarTitleColor = color
    }
    
    private func setNavigationBarXmarkColor(_ color: UIColor) {
        self.navigationBarXmarkColor = color
    }
    
    private func setTableViewBackgroundColor(_ color: UIColor) {
        self.tableViewBackgroundColor = color
    }
    
    private func setTableViewSectionTitleColor(_ color: UIColor) {
        self.tableViewSectionTitleColor = color
    }
    
    private func setTableViewSectionCellBackgroundColor(_ color: UIColor) {
        self.tableViewSectionCellBackgroundColor = color
    }
    
    private func setTableViewSectionCellTitleColor(_ color: UIColor) {
        self.tableViewSectionCellTitleColor = color
    }
    
    private func setTableViewSectionCellSwitchOnTintColor(_ color: UIColor) {
        self.tableViewSectionCellSwitchOnTintColor = color
    }
    
    private func setTableViewSectionCellSwitchThumbTintColor(_ color: UIColor) {
        self.tableViewSectionCellSwitchThumbTintColor = color
    }
}

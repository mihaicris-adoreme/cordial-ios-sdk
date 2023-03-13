//
//  NotificationSettingsTableViewTapGestureRecognizer.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 07.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
class NotificationSettingsTableViewTapGestureRecognizer: UITapGestureRecognizer {
    
    var indexPath: IndexPath = []
    var sender = NotificationSettingsTableViewController()
    
    convenience init(indexPath: IndexPath, sender: NotificationSettingsTableViewController, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        
        self.indexPath = indexPath
        self.sender = sender
    }
}

//
//  PushNotificationSettingsTableViewCellTapGestureRecognizer.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 09.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class PushNotificationSettingsTableViewCellTapGestureRecognizer: NSObject {
    
    static func setup(cell: PushNotificationSettingsTableViewCell, indexPath: IndexPath, sender: UIViewController) {
        if #available(iOS 14.0, *), let sender = sender as? PushNotificationSettingsTableViewController {
            let tapGestureRecognizer = PushNotificationSettingsTableViewTapGestureRecognizer(indexPath: indexPath, sender: sender, target: sender, action: #selector(self.colorImageTapped(_:)))
            cell.colorImage.isUserInteractionEnabled = true
            cell.colorImage.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @available(iOS 14.0, *)
    @objc static func colorImageTapped(_ tapGestureRecognizer: PushNotificationSettingsTableViewTapGestureRecognizer) {
        let sender = tapGestureRecognizer.sender
        self.method(for: #selector(sender.colorImageTapped(_:)))
    }
}

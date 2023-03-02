//
//  CustomUIActivityPushNotificationSettings.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 02.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class CustomUIActivityPushNotificationSettings: UIActivity {

    var sender: UIViewController
    
    init(sender: UIViewController) {
        self.sender = sender
    }
    
    override class var activityCategory: UIActivity.Category {
        return .action
    }

    override var activityType: UIActivity.ActivityType? {
        return .customUIActivity
    }

    override var activityTitle: String? {
        return "Notification Settings"
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        switch self.sender {
        case is CatalogCollectionViewController:
            let catalogCollectionViewController = self.sender as! CatalogCollectionViewController
                        
            self.activityDidFinish(true)
            
            let identifier = catalogCollectionViewController.segueToPushNotificationSettings
            catalogCollectionViewController.performSegue(withIdentifier: identifier, sender: self)
        default:
            break
        }
    }
}

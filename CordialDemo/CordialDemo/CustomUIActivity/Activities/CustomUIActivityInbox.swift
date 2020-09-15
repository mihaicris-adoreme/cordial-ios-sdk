//
//  CustomUIActivityInbox.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 31.08.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class CustomUIActivityInbox: UIActivity {

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
        return "Inbox"
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        switch self.sender {
        case is CatalogCollectionViewController:
            let catalogCollectionViewController = self.sender as! CatalogCollectionViewController
            
            self.activityDidFinish(true)
            
            let identifier = catalogCollectionViewController.segueToInboxIdentifier
            catalogCollectionViewController.performSegue(withIdentifier: identifier, sender: self)
        default:
            break
        }
    }
}

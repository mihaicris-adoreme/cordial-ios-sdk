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
            
            let alert = UIAlertController(title: "Inbox", message: "Please select the view", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "List", style: .default) { action in
                let identifier = catalogCollectionViewController.segueToInboxTableListIdentifier
                catalogCollectionViewController.performSegue(withIdentifier: identifier, sender: self)
            })
            
            alert.addAction(UIAlertAction(title: "Cards", style: .default) { action in
                let identifier = catalogCollectionViewController.segueToInboxCollectionIdentifier
                catalogCollectionViewController.performSegue(withIdentifier: identifier, sender: self)
            })
            
            alert.addAction(UIAlertAction(title: "Raw", style: .default) { action in
                let identifier = catalogCollectionViewController.segueToInboxTableIdentifier
                catalogCollectionViewController.performSegue(withIdentifier: identifier, sender: self)
            })
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            
            catalogCollectionViewController.present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
}

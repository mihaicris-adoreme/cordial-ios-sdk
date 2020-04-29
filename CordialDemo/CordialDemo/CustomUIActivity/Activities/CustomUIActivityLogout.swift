//
//  CustomUIActivityLogout.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 22.04.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit

class CustomUIActivityLogout: UIActivity {

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
        return "Log out"
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        switch self.sender {
        case is CatalogCollectionViewController:
            let catalogCollectionViewController = self.sender as! CatalogCollectionViewController
            
            self.activityDidFinish(true)
            
            catalogCollectionViewController.logoutAction()
        default:
            break
        }
    }
}

//
//  CustomUIActivityProfile.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 21.04.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit

class CustomUIActivityProfile: UIActivity {

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
        return "Profile"
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        switch self.sender {
        case is CatalogCollectionViewController:
            let catalogCollectionViewController = self.sender as! CatalogCollectionViewController
                        
            self.activityDidFinish(true)
            
            let identifier = catalogCollectionViewController.segueToProfileIdentifier
            catalogCollectionViewController.performSegue(withIdentifier: identifier, sender: self)
        default:
            break
        }
    }
}

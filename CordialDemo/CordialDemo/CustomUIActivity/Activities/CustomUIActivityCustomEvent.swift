//
//  CustomUIActivityCustomEvent.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 22.04.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit

class CustomUIActivityCustomEvent: UIActivity {

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
        return "Send Custom Event"
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        switch self.sender {
        case is CatalogCollectionViewController:
            let catalogCollectionViewController = self.sender as! CatalogCollectionViewController
                        
            self.activityDidFinish(true)
            
            let identifier = catalogCollectionViewController.segueToCustomEventIdentifier
            catalogCollectionViewController.performSegue(withIdentifier: identifier, sender: self)
        default:
            break
        }
    }
}


//
//  CustomUIActivityFetchInboxMessages.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 31.08.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK
import os.log

class CustomUIActivityFetchInboxMessages: UIActivity {

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
        return "Fetch Inbox Messages"
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        switch self.sender {
        case is CatalogCollectionViewController:
            let catalogCollectionViewController = self.sender as! CatalogCollectionViewController
            
            self.activityDidFinish(true)
            
            CordialInboxMessageAPI().fetchInboxMessages(onSuccess: { response in
                popupSimpleNoteAlert(title: "SUCCESS", message: "DETAILS IN THE CONSOLE", controller: catalogCollectionViewController)
                
                if response.count > 0 {
                    response.forEach { message in
                        os_log("Inbox message: \n ID: %{public}@ \n HTML: %{public}@ \n customKeyValuePairs: %{public}@ \n title: %{public}@ \n read: %{public}@ \n sentAt: %{public}@", log: OSLog.сordialSDKDemoInboxMessages, type: .info, message.id, message.html, message.customKeyValuePairs.description, message.title, message.read.description, message.sentAt)
                    }
                } else {
                    os_log("Inbox is empty", log: OSLog.сordialSDKDemoInboxMessages, type: .info)
                }
            }, onFailure: { error in
                popupSimpleNoteAlert(title: "FAILED", message: "DETAILS IN THE CONSOLE", controller: catalogCollectionViewController)
                
                os_log("%{public}@", log: OSLog.сordialSDKDemoInboxMessages, type: .error, error)
            })
            
        default:
            break
        }
    }
}

//
//  CordialContinueRestorationDelegate.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/24/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public protocol CordialContinueRestorationDelegate {
    
    @objc func appOpenViaUniversalLink(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    
}

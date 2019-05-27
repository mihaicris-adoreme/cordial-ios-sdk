//
//  CordialOpenOptionsDelegate.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

public protocol CordialOpenOptionsDelegate {
    
    func appOpenViaUrlScheme(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
    
}

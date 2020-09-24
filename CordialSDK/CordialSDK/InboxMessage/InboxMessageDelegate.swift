//
//  InboxMessageDelegate.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 24.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

@objc public protocol InboxMessageDelegate {
    
    @objc func newInboxMessageDelivered(mcID: String)
    
}

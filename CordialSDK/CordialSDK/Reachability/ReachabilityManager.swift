//
//  ReachabilityManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class ReachabilityManager {
    
    public static let shared = ReachabilityManager()
    
    let reachability = Reachability()!
    public var isConnectedToInternet = true
    
    private init() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: .reachabilityChanged, object: nil)
        notificationCenter.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        
        do {
            try reachability.startNotifier()
        } catch {
            os_log("ReachabilityManager: Could not start reachability notifier", log: OSLog.cordialError, type: .error)
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            isConnectedToInternet = true
            NotificationCenter.default.post(name: .connectedToInternet, object: nil)
        case .cellular:
            isConnectedToInternet = true
            NotificationCenter.default.post(name: .connectedToInternet, object: nil)
        case .none:
            isConnectedToInternet = false
            NotificationCenter.default.post(name: .notConnectedToInternet, object: nil)
        }
    }
    
}

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
    
    static let shared = ReachabilityManager()
    
    let reachability = Reachability()!
    var isConnectedToInternet = true
    
    private init() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: .reachabilityChanged, object: nil)
        notificationCenter.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        
        do {
            try reachability.startNotifier()
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Could not start reachability notifier. Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
            }
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

//
//  ReachabilityManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class ReachabilityManager {
    
    static let shared = ReachabilityManager()
    
    let reachability = Reachability()!
    var isConnectedToInternet = true
    
    private init() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: .cordialReachabilityChanged, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialReachabilityChanged(note:)), name: .cordialReachabilityChanged, object: reachability)
        
        do {
            try reachability.startNotifier()
        } catch let error {
            LoggerManager.shared.error(message: "Could not start reachability notifier. Error: [\(error.localizedDescription)]", category: "CordialSDKError")
        }
    }
    
    @objc func cordialReachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            isConnectedToInternet = true
            NotificationCenter.default.post(name: .cordialConnectedToInternet, object: nil)
        case .cellular:
            isConnectedToInternet = true
            NotificationCenter.default.post(name: .cordialConnectedToInternet, object: nil)
        case .none:
            isConnectedToInternet = false
            NotificationCenter.default.post(name: .cordialNotConnectedToInternet, object: nil)
        }
    }
    
}

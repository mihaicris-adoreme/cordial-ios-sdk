//
//  ReachabilitySender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/25/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation


class ReachabilitySender {
    
    static let shared = ReachabilitySender()
    
    private init(){
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: .cordialConnectedToInternet, object: nil)
        notificationCenter.addObserver(self, selector: #selector(makeAllNeededHTTPCalls), name: .cordialConnectedToInternet, object: nil)
    }
    
    @objc func makeAllNeededHTTPCalls() {
        CoreDataManager.shared.coreDataSender.startSendCachedCustomEventRequestsScheduledTimer()
        DispatchQueue.main.async {
            InternalCordialAPI().sendFirstLaunchCustomEvent()
            CoreDataManager.shared.coreDataSender.sendCacheFromCoreData()
        }
    }
    
}

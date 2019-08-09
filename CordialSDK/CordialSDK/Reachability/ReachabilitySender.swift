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
        
        notificationCenter.removeObserver(self, name: .connectedToInternet, object: nil)
        notificationCenter.addObserver(self, selector: #selector(makeAllNeededHTTPCalls), name: .connectedToInternet, object: nil)
    }
    
    @objc private func makeAllNeededHTTPCalls() {
        let internalCordialAPI = InternalCordialAPI()
        
        internalCordialAPI.sendFirstLaunchCustomEvent()
        internalCordialAPI.sendCacheFromCoreData()
    }
    
}

//
//  ReachabilitySender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/25/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class ReachabilitySender {
    
    public static let shared = ReachabilitySender()
    
    private init(){
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: .connectedToInternet, object: nil)
        notificationCenter.addObserver(self, selector: #selector(sendCacheFromCoreData), name: .connectedToInternet, object: nil)
    }
    
    @objc private func sendCacheFromCoreData() {
        let customEventRequests = CoreDataManager.shared.customEventRequests.getCustomEventRequestsFromCoreData()
        if customEventRequests.count > 0 {
            CustomEventsSender().sendCustomEvents(sendCustomEventRequests: customEventRequests)
        }
        
        if let upsertContactCartRequest = CoreDataManager.shared.contactCartRequest.getContactCartRequestToCoreData() {
            ContactCartSender().upsertContactCart(upsertContactCartRequest: upsertContactCartRequest)
        }
        
        let sendContactOrderRequests = CoreDataManager.shared.contactOrderRequests.getContactOrderRequestsFromCoreData()
        if sendContactOrderRequests.count > 0 {
            ContactOrdersSender().sendContactOrders(sendContactOrderRequests: sendContactOrderRequests)
        }
        
        let upsertContactRequests = CoreDataManager.shared.contactRequests.getContactRequestsFromCoreData()
        if upsertContactRequests.count > 0 {
            ContactsSender().upsertContactRequests(upsertContactRequests: upsertContactRequests)
        }
    }
}

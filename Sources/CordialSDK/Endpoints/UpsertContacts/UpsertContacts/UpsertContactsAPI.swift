//
//  UpsertContactsAPI.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 22.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation

@objcMembers public class UpsertContactsAPI: NSObject {
    
    private let internalCordialAPI = InternalCordialAPI()
    
    public func getDeviceIdentifier() -> String {
        return self.internalCordialAPI.getDeviceIdentifier()
    }
    
    public func getPushNotificationToken() -> String? {
        return self.internalCordialAPI.getPushNotificationToken()
    }
    
    public func getPushNotificationStatus() -> String {
        return self.internalCordialAPI.getPushNotificationStatus()
    }
    
    public func getContactAttributes() -> Dictionary<String, AttributeValue>? {
        return nil
    }
}

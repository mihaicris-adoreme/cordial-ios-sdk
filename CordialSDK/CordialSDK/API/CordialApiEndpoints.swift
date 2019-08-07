//
//  CordialApiEndpoints.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/11/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class CordialApiEndpoints {
    
    let cordialAPI = CordialAPI()
    
    func getCustomEventsURL() -> String {
        let baseURL = cordialAPI.getBaseURL()
        
        return "\(baseURL)mobile/events"
    }
    
    func getContactsURL() -> String {
        let baseURL = cordialAPI.getBaseURL()
        
        return "\(baseURL)mobile/contacts"
    }
    
    func getContactLogoutURL() -> String {
        let baseURL = cordialAPI.getBaseURL()
        
        return "\(baseURL)mobile/contact/logout"
    }
    
    func getСontactСartURL() -> String {
        let baseURL = cordialAPI.getBaseURL()
        
        return "\(baseURL)mobile/contact/cart"
    }
    
    func getOrdersURL() -> String {
        let baseURL = cordialAPI.getBaseURL()
        
        return "\(baseURL)mobile/orders"
    }
    
    func getInAppMessageURL(mcID: String) -> String {
        let baseURL = cordialAPI.getBaseURL()
        
        return "\(baseURL)mobile/message/\(mcID)"
    }
    
    func getSDKSecurityURL(secret: String) -> String {
        let baseURL = cordialAPI.getBaseURL()
        
        return "\(baseURL)mobile/auth/\(secret)"
    }
}

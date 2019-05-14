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
    
    func getEventsURL() -> String {
        return cordialAPI.getBaseURL() + "mobile/events"
    }
    
    func getContactURL() -> String {
        return cordialAPI.getBaseURL() + "mobile/contact"
    }
    
    func getContactsURL() -> String {
        return cordialAPI.getBaseURL() + "mobile/contacts"
    }
    
    func getСontactСartURL() -> String {
        return cordialAPI.getBaseURL() + "mobile/contact/cart"
    }
    
    func getOrdersURL() -> String {
        return cordialAPI.getBaseURL() + "/mobile/orders"
    }
}

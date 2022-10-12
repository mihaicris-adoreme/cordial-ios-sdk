//
//  CordialPushNotificationParserCarusel.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 12.10.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation

class CordialPushNotificationParserCarusel {
    
    // MARK: Is payload contain carusel
    
    func isPayloadContainCaruselCurrentPayloadType(userInfo: [AnyHashable : Any]) -> Bool {
        if let carousel = userInfo["carousel"] as? [AnyObject],
           !carousel.isEmpty {
            
            return true
        }
        
        return false
    }
    
}

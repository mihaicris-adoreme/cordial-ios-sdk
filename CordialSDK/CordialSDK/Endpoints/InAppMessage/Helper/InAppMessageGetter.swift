//
//  InAppMessageGetter.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/3/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class InAppMessageGetter {
    
    func getInAppMessage(mcID: String) {
        if ReachabilityManager.shared.isConnectedToInternet {
            let inAppMessage = InAppMessage()
            
            inAppMessage.getInAppMessage(mcID: mcID,
                onSuccess: { result in
                    
                }, systemError: { error in
                    
                }, logicError: { error in
                    
                }
            )
        } else {
            
        }
    }
    
}

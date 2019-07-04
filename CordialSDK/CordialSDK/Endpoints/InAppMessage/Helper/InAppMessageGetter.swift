//
//  InAppMessageGetter.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/3/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class InAppMessageGetter {
    
    func fetchInAppMessage(mcID: String) {
        if ReachabilityManager.shared.isConnectedToInternet {
            let inAppMessage = InAppMessage()
            
            inAppMessage.getInAppMessage(mcID: mcID,
                onSuccess: { html in
                    let inAppMessageData = InAppMessageData(mcID: mcID, html: html)
                    CoreDataManager.shared.inAppMessageCache.setInAppMessageDataToCoreData(inAppMessageData: inAppMessageData)
                }, systemError: { error in
                    
                }, logicError: { error in
                    
                }
            )
        } else {
            
        }
    }
    
}

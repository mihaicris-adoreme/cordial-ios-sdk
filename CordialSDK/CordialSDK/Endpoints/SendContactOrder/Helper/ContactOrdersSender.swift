//
//  ContactOrdersSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/26/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class ContactOrdersSender {
    
    func sendContactOrders(sendContactOrderRequests: [SendContactOrderRequest]) {
        if ReachabilityManager.shared.isConnectedToInternet && CordialAPI().getContactPrimaryKey() != nil {
            let sendContactOrders = SendContactOrders()
            
            os_log("Sending contact orders:", log: OSLog.sendContactOrders, type: .info)
            sendContactOrderRequests.forEach({ sendContactOrderRequest in
                os_log("Order ID: [%{public}@]", log: OSLog.sendContactOrders, type: .info, sendContactOrderRequest.order.orderID)
            })
            
            sendContactOrders.sendContactOrders(sendContactOrderRequests: sendContactOrderRequests,
                onSuccess: { result in
                    os_log("Orders sent:", log: OSLog.sendContactOrders, type: .info)
                    sendContactOrderRequests.forEach({ sendContactOrderRequest in
                        os_log("Order ID: [%{public}@]", log: OSLog.sendContactOrders, type: .info, sendContactOrderRequest.order.orderID)
                    })
                }, systemError: { error in
                    CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: sendContactOrderRequests)
                    os_log("Sending contact order failed. Saved to retry later. Error: [%{public}@]", log: OSLog.sendContactOrders, type: .info, error.message)
                }, logicError: { error in
                    NotificationCenter.default.post(name: .sendContactOrdersLogicError, object: error)
                    os_log("Sending contact order failed. Will not retry. For viewing exact error see .sendContactOrdersLogicError notification in notification center.", log: OSLog.sendContactOrders, type: .info)
                }
            )
        } else {
            CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: sendContactOrderRequests)
            os_log("Sending contact order failed. Saved to retry later. Error: [No Internet connection.]", log: OSLog.sendContactOrders, type: .info)
        }
    }
}

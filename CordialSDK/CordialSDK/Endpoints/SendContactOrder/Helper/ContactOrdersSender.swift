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
                os_log("Order ID: [%{PUBLIC}@]", log: OSLog.sendContactOrders, type: .info, sendContactOrderRequest.order.orderID)
            })
            
            sendContactOrders.sendContactOrders(sendContactOrderRequests: sendContactOrderRequests,
                onSuccess: { result in
                    os_log("Orders sent:", log: OSLog.sendContactOrders, type: .info)
                    sendContactOrderRequests.forEach({ sendContactOrderRequest in
                        os_log("Order ID: [%{PUBLIC}@]", log: OSLog.sendContactOrders, type: .info, sendContactOrderRequest.order.orderID)
                    })
                }, systemError: { error in
                    CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: sendContactOrderRequests)
                    os_log("Sending contact order failed. Saved to retry later.", log: OSLog.sendContactOrders, type: .info)
                }, logicError: { error in
                    NotificationCenter.default.post(name: .sendContactOrdersLogicError, object: error)
                    os_log("Sending contact order failed. Will not retry.", log: OSLog.sendContactOrders, type: .info)
                }
            )
        } else {
            CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: sendContactOrderRequests)
            os_log("Sending contact order failed. Saved to retry later.", log: OSLog.sendContactOrders, type: .info)
        }
    }
}

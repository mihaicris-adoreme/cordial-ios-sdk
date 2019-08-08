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
            
            os_log("Sending contact orders:", log: OSLog.cordialSendContactOrders, type: .info)
            sendContactOrderRequests.forEach({ sendContactOrderRequest in
                os_log("Order ID: [%{public}@]", log: OSLog.cordialSendContactOrders, type: .info, sendContactOrderRequest.order.orderID)
            })
            
            sendContactOrders.sendContactOrders(sendContactOrderRequests: sendContactOrderRequests)
        } else {
            CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: sendContactOrderRequests)
            os_log("Sending contact order failed. Saved to retry later. Error: [No Internet connection.]", log: OSLog.cordialSendContactOrders, type: .info)
        }
    }
    
    func completionHandler(sendContactOrderRequests: [SendContactOrderRequest]) {
        os_log("Orders sent:", log: OSLog.cordialSendContactOrders, type: .info)
        sendContactOrderRequests.forEach({ sendContactOrderRequest in
            os_log("Order ID: [%{public}@]", log: OSLog.cordialSendContactOrders, type: .info, sendContactOrderRequest.order.orderID)
        })
    }
    
    func systemErrorHandler(sendContactOrderRequests: [SendContactOrderRequest], error: ResponseError) {
        CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: sendContactOrderRequests)
        os_log("Sending contact order failed. Saved to retry later. Error: [%{public}@]", log: OSLog.cordialSendContactOrders, type: .info, error.message)
    }
    
    func logicErrorHandler(error: ResponseError) {
        NotificationCenter.default.post(name: .cordialSendContactOrdersLogicError, object: error)
        os_log("Sending contact order failed. Will not retry. For viewing exact error see .cordialSendContactOrdersLogicError notification in notification center.", log: OSLog.cordialSendContactOrders, type: .info)
    }
}

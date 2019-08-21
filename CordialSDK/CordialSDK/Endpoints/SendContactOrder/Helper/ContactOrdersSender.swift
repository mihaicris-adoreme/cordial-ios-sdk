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
        if ReachabilityManager.shared.isConnectedToInternet {
            self.sendContactOrdersIfUserLoggedIn(sendContactOrderRequests: sendContactOrderRequests)
        } else {
            CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: sendContactOrderRequests)
            
            if OSLogManager.shared.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Sending contact order failed. Saved to retry later. Error: [No Internet connection]", log: OSLog.cordialSendContactOrders, type: .info)
            }
        }
    }
    
    func completionHandler(sendContactOrderRequests: [SendContactOrderRequest]) {
        if OSLogManager.shared.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Orders sent:", log: OSLog.cordialSendContactOrders, type: .info)
            sendContactOrderRequests.forEach({ sendContactOrderRequest in
                os_log("Order ID: [%{public}@]", log: OSLog.cordialSendContactOrders, type: .info, sendContactOrderRequest.order.orderID)
            })
        }
    }
    
    func systemErrorHandler(sendContactOrderRequests: [SendContactOrderRequest], error: ResponseError) {
        CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: sendContactOrderRequests)
        
        if OSLogManager.shared.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Sending contact order failed. Saved to retry later. Error: [%{public}@]", log: OSLog.cordialSendContactOrders, type: .info, error.message)
        }
    }
    
    func logicErrorHandler(error: ResponseError) {
        NotificationCenter.default.post(name: .cordialSendContactOrdersLogicError, object: error)
        
        if OSLogManager.shared.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Sending contact order failed. Will not retry. For viewing exact error see .cordialSendContactOrdersLogicError notification in notification center.", log: OSLog.cordialSendContactOrders, type: .info)
        }
    }
    
    private func sendContactOrdersIfUserLoggedIn(sendContactOrderRequests: [SendContactOrderRequest]) {
        if CordialAPI().getContactPrimaryKey() != nil {
            let sendContactOrders = SendContactOrders()
            
            if OSLogManager.shared.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Sending contact orders:", log: OSLog.cordialSendContactOrders, type: .info)
                sendContactOrderRequests.forEach({ sendContactOrderRequest in
                    os_log("Order ID: [%{public}@]", log: OSLog.cordialSendContactOrders, type: .info, sendContactOrderRequest.order.orderID)
                })
            }
            
            if InternalCordialAPI().getCurrentJWT() != nil {
                sendContactOrders.sendContactOrders(sendContactOrderRequests: sendContactOrderRequests)
            } else {
                let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
                self.systemErrorHandler(sendContactOrderRequests: sendContactOrderRequests, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            }
        } else {
            CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: sendContactOrderRequests)
            
            if OSLogManager.shared.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Sending contact order failed. Saved to retry later. Error: [primaryKey is nil]", log: OSLog.cordialSendContactOrders, type: .info)
            }
        }
    }
}

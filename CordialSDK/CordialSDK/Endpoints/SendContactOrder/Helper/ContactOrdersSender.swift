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
    
    let sendContactOrders = SendContactOrders()
    
    func sendContactOrders(sendContactOrderRequests: [SendContactOrderRequest]) {
        
        if InternalCordialAPI().isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                self.sendContactOrdersData(sendContactOrderRequests: sendContactOrderRequests)
            } else {
                CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: sendContactOrderRequests)
                
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    sendContactOrderRequests.forEach({ sendContactOrderRequest in
                        os_log("Sending contact order failed. Saved to retry later. Request ID: [%{public}@] Error: [No Internet connection]", log: OSLog.cordialSendContactOrders, type: .info, sendContactOrderRequest.order.orderID)
                    })
                }
            }
        } else {
            CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: sendContactOrderRequests)
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                sendContactOrderRequests.forEach({ sendContactOrderRequest in
                    os_log("Sending contact order failed. Saved to retry later. Request ID: [%{public}@] Error: [User no login]", log: OSLog.cordialSendContactOrders, type: .info, sendContactOrderRequest.order.orderID)
                })
            }
        }
    }
    
    private func sendContactOrdersData(sendContactOrderRequests: [SendContactOrderRequest]) {
        if !ContactsSender.shared.isCurrentlyUpsertingContactsData {
            let sendContactOrders = SendContactOrders()
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                sendContactOrderRequests.forEach({ sendContactOrderRequest in
                    os_log("Sending contact order. Request ID: [%{public}@]", log: OSLog.cordialSendContactOrders, type: .info, sendContactOrderRequest.order.orderID)
                    
                    let payload = self.sendContactOrders.getSendContactOrderRequestJSON(sendContactOrderRequest: sendContactOrderRequest)
                    os_log("Payload: %{public}@", log: OSLog.cordialSendContactOrders, type: .info, payload)
                })
            }
            
            if InternalCordialAPI().getCurrentJWT() != nil {
                sendContactOrders.sendContactOrders(sendContactOrderRequests: sendContactOrderRequests)
            } else {
                let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
                self.systemErrorHandler(sendContactOrderRequests: sendContactOrderRequests, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            }
        } 
    }
    
    func completionHandler(sendContactOrderRequests: [SendContactOrderRequest]) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            sendContactOrderRequests.forEach({ sendContactOrderRequest in
                os_log("Order has been sent. Request ID: [%{public}@]", log: OSLog.cordialSendContactOrders, type: .info, sendContactOrderRequest.order.orderID)
            })
        }
    }
    
    func systemErrorHandler(sendContactOrderRequests: [SendContactOrderRequest], error: ResponseError) {
        CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: sendContactOrderRequests)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            sendContactOrderRequests.forEach({ sendContactOrderRequest in
                os_log("Sending contact order failed. Saved to retry later. Request ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialSendContactOrders, type: .info, sendContactOrderRequest.order.orderID, error.message)
            })
        }
    }
    
    func logicErrorHandler(sendContactOrderRequests: [SendContactOrderRequest], error: ResponseError) {
        NotificationCenter.default.post(name: .cordialSendContactOrdersLogicError, object: error)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            sendContactOrderRequests.forEach({ sendContactOrderRequest in
                os_log("Sending contact order failed. Will not retry. Request ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialSendContactOrders, type: .error, sendContactOrderRequest.order.orderID, error.message)
            })
        }
    }
    
}

//
//  ContactOrdersSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/26/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class ContactOrdersSender {
    
    let sendContactOrders = SendContactOrders()
    
    func sendContactOrders(sendContactOrderRequests: [SendContactOrderRequest]) {
        
        if InternalCordialAPI().isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                self.sendContactOrdersData(sendContactOrderRequests: sendContactOrderRequests)
            } else {
                CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: sendContactOrderRequests)
                
                sendContactOrderRequests.forEach({ sendContactOrderRequest in
                    LoggerManager.shared.info(message: "Sending contact order failed. Saved to retry later. Request ID: [\(sendContactOrderRequest.order.orderID)] Error: [No Internet connection]", category: "CordialSDKSendContactOrders")
                })
            }
        } else {
            CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: sendContactOrderRequests)
            
            sendContactOrderRequests.forEach({ sendContactOrderRequest in
                LoggerManager.shared.info(message: "Sending contact order failed. Saved to retry later. Request ID: [\(sendContactOrderRequest.order.orderID)] Error: [User no login]", category: "CordialSDKSendContactOrders")
            })
        }
    }
    
    private func sendContactOrdersData(sendContactOrderRequests: [SendContactOrderRequest]) {
        let sendContactOrders = SendContactOrders()
                
        if InternalCordialAPI().getCurrentJWT() != nil {
            sendContactOrderRequests.forEach({ sendContactOrderRequest in
                LoggerManager.shared.info(message: "Sending contact order. Request ID: [\(sendContactOrderRequest.order.orderID)]", category: "CordialSDKSendContactOrders")
                
                let payload = self.sendContactOrders.getSendContactOrderRequestJSON(sendContactOrderRequest: sendContactOrderRequest)
                LoggerManager.shared.info(message: "Payload: \(payload)", category: "CordialSDKSendContactOrders")
            })
            
            sendContactOrders.sendContactOrders(sendContactOrderRequests: sendContactOrderRequests)
        } else {
            let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
            self.systemErrorHandler(sendContactOrderRequests: sendContactOrderRequests, error: responseError)
            
            SDKSecurity.shared.updateJWT()
        }
    }
    
    func completionHandler(sendContactOrderRequests: [SendContactOrderRequest]) {
        sendContactOrderRequests.forEach({ sendContactOrderRequest in
            LoggerManager.shared.info(message: "Order has been sent. Request ID: [\(sendContactOrderRequest.order.orderID)]", category: "CordialSDKSendContactOrders")
        })
    }
    
    func systemErrorHandler(sendContactOrderRequests: [SendContactOrderRequest], error: ResponseError) {
        CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: sendContactOrderRequests)
        
        sendContactOrderRequests.forEach({ sendContactOrderRequest in
            LoggerManager.shared.info(message: "Sending contact order failed. Saved to retry later. Request ID: [\(sendContactOrderRequest.order.orderID)] Error: [\(error.message)]", category: "CordialSDKSendContactOrders")
        })
    }
    
    func logicErrorHandler(sendContactOrderRequests: [SendContactOrderRequest], error: ResponseError) {
        NotificationCenter.default.post(name: .cordialSendContactOrdersLogicError, object: error)
        
        sendContactOrderRequests.forEach({ sendContactOrderRequest in
            LoggerManager.shared.error(message: "Sending contact order failed. Will not retry. Request ID: [\(sendContactOrderRequest.order.orderID)] Error: [\(error.message)]", category: "CordialSDKSendContactOrders")
        })
    }
    
}

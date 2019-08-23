//
//  SendContactOrders.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/23/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class SendContactOrders {
    
    func sendContactOrders(sendContactOrderRequests: [SendContactOrderRequest]) {
        if let url = URL(string: CordialApiEndpoints().getOrdersURL()) {
            var request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .POST)
            
            let sendContactOrderJSON = getSendContactOrderRequestsJSON(sendContactOrderRequests: sendContactOrderRequests)
            request.httpBody = sendContactOrderJSON.data(using: .utf8)
            
            let sendContactOrdersDownloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
            
            let sendContactOrdersURLSessionData = SendContactOrdersURLSessionData(sendContactOrderRequests: sendContactOrderRequests)
            let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_SEND_CONTACT_ORDERS, taskData: sendContactOrdersURLSessionData)
            CordialURLSession.shared.operations[sendContactOrdersDownloadTask.taskIdentifier] = cordialURLSessionData
            
            sendContactOrdersDownloadTask.resume()
        }
    }
    
    func getSendContactOrderRequestsJSON(sendContactOrderRequests: [SendContactOrderRequest]) -> String {
        var sendContactOrdersArrayJSON = [String]()
        
        sendContactOrderRequests.forEach { sendContactOrderRequest in
            let orderJSON = self.getOrderJSON(order: sendContactOrderRequest.order)
            
            var rootContainer  = [
                "\"deviceId\": \"\(sendContactOrderRequest.deviceID)\"",
                "\"order\": \(orderJSON)"
            ]
            
            if let primaryKey = sendContactOrderRequest.primaryKey {
                rootContainer.append("\"primaryKey\": \"\(primaryKey)\"")
            }
            
            let rootContainerString = rootContainer.joined(separator: ", ")
            
            let stringJSON = "{ \(rootContainerString) }"
            
            sendContactOrdersArrayJSON.append(stringJSON)
        }
        
        let sendContactOrdersStringJSON = sendContactOrdersArrayJSON.joined(separator: ", ")
        
        let sendContactOrderJSON = "[ \(sendContactOrdersStringJSON) ]"
        
        return sendContactOrderJSON
    }

    private func getOrderJSON(order: Order) -> String {
        
        var orderContainer  = [
            "\"orderID\": \"\(order.orderID)\"",
            "\"status\": \"\(order.status)\"",
            "\"storeID\": \"\(order.storeID)\"",
            "\"customerID\": \"\(order.customerID)\"",
            "\"purchaseDate\": \"\(ISO8601DateFormatter().string(from: order.purchaseDate))\"",
            "\"shippingAddress\": \(self.getAddressJSON(address: order.shippingAddress))",
            "\"billingAddress\": \(self.getAddressJSON(address: order.billingAddress))",
            "\"items\": \(UpsertContactCart().getCartItemsJSON(cartItems: order.items))"
        ]
        
        if let tax = order.tax {
            orderContainer.append("\"tax\": \"\(tax)\"")
        }
        
        if let shippingAndHandling = order.shippingAndHandling {
            orderContainer.append("\"shippingAndHandling\": \"\(shippingAndHandling)\"")
        }
    
        if let properties = order.properties {
            orderContainer.append("\"properties\": \(API.getDictionaryJSON(stringDictionary: properties))")
        }
        
        let orderContainerString = orderContainer.joined(separator: ", ")
        
        return "{ \(orderContainerString) }"
    }
    
    private func getAddressJSON(address: Address) -> String {
        let addressContainer  = [
            "\"name\": \"\(address.name)\"",
            "\"address\": \"\(address.address)\"",
            "\"city\": \"\(address.city)\"",
            "\"state\": \"\(address.state)\"",
            "\"postalCode\": \"\(address.postalCode)\"",
            "\"country\": \"\(address.country)\""
        ]
        
        let addressContainerString = addressContainer.joined(separator: ", ")
        
        return "{ \(addressContainerString) }"
    }
    
}

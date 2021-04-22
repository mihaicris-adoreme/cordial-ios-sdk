//
//  SendContactOrders.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/23/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class SendContactOrders {
    
    let cordialAPI = CordialAPI()
    let internalCordialAPI = InternalCordialAPI()
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    func sendContactOrders(sendContactOrderRequests: [SendContactOrderRequest]) {
        if let url = URL(string: CordialApiEndpoints().getOrdersURL()) {
            var request = CordialRequestFactory().getCordialURLRequest(url: url, httpMethod: .POST)
            
            let sendContactOrderJSON = getSendContactOrderRequestsJSON(sendContactOrderRequests: sendContactOrderRequests)
            request.httpBody = sendContactOrderJSON.data(using: .utf8)
            
            let downloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
            
            let sendContactOrdersURLSessionData = SendContactOrdersURLSessionData(sendContactOrderRequests: sendContactOrderRequests)
            let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_SEND_CONTACT_ORDERS, taskData: sendContactOrdersURLSessionData)
            CordialURLSession.shared.setOperation(taskIdentifier: downloadTask.taskIdentifier, data: cordialURLSessionData)
            
            self.requestSender.sendRequest(task: downloadTask)
        }
    }
    
    private func getSendContactOrderRequestsJSON(sendContactOrderRequests: [SendContactOrderRequest]) -> String {
        var sendContactOrdersArrayJSON = [String]()
        
        sendContactOrderRequests.forEach { sendContactOrderRequest in
            let sendContactOrderJSON = self.getSendContactOrderRequestJSON(sendContactOrderRequest: sendContactOrderRequest)
            
            sendContactOrdersArrayJSON.append(sendContactOrderJSON)
        }
        
        let sendContactOrdersStringJSON = sendContactOrdersArrayJSON.joined(separator: ", ")
        
        let sendContactOrderJSON = "[ \(sendContactOrdersStringJSON) ]"
        
        return sendContactOrderJSON
    }

    internal func getSendContactOrderRequestJSON(sendContactOrderRequest: SendContactOrderRequest) -> String {
        let orderJSON = self.getOrderJSON(order: sendContactOrderRequest.order)
        
        var rootContainer  = [
            "\"deviceId\": \"\(internalCordialAPI.getDeviceIdentifier())\"",
            "\"order\": \(orderJSON)"
        ]
        
        if let primaryKey = self.cordialAPI.getContactPrimaryKey() {
            rootContainer.append("\"primaryKey\": \"\(primaryKey)\"")
        }
        
        if let mcID = sendContactOrderRequest.mcID, let mcTapTime = self.internalCordialAPI.getMcTapTime() {
            rootContainer.append("\"mcID\": \"\(mcID)\"")
            rootContainer.append("\"mcTapTime\": \"\(mcTapTime)\"")
        }
        
        let rootContainerString = rootContainer.joined(separator: ", ")
        
        return "{ \(rootContainerString) }"
    }
    
    private func getOrderJSON(order: Order) -> String {
        
        var orderContainer  = [
            "\"orderID\": \"\(order.orderID)\"",
            "\"status\": \"\(order.status)\"",
            "\"storeID\": \"\(order.storeID)\"",
            "\"customerID\": \"\(order.customerID)\"",
            "\"purchaseDate\": \"\(CordialDateFormatter().getTimestampFromDate(date: order.purchaseDate))\"",
            "\"shippingAddress\": \(self.getAddressJSON(address: order.shippingAddress))",
            "\"billingAddress\": \(self.getAddressJSON(address: order.billingAddress))",
            "\"items\": \(UpsertContactCart().getCartItemsJSON(cartItems: order.items))"
        ]
        
        if let tax = order.tax {
            orderContainer.append("\"tax\": \"\(tax)\"")
        }
        
        if let shippingAndHandling = order.shippingAndHandling {
            orderContainer.append("\"shippingAndHandling\": \(shippingAndHandling)")
        }
    
        if let properties = order.properties {
            orderContainer.append("\"properties\": \(API.getDictionaryJSON(properties))")
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

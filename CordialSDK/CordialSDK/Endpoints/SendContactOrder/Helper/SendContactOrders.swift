//
//  SendContactOrders.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/23/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class SendContactOrders {
    
    func sendContactOrders(sendContactOrderRequests: [SendContactOrderRequest], onSuccess: @escaping (SendContactOrderResponse) -> Void, systemError: @escaping (ResponseError) -> Void, logicError: @escaping (ResponseError) -> Void) -> Void {
        if let url = URL(string: CordialApiEndpoints().getOrdersURL()) {
            var request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .POST)
            
            let sendContactOrderJSON = getSendContactOrderRequestsJSON(sendContactOrderRequests: sendContactOrderRequests)
            request.httpBody = sendContactOrderJSON.data(using: .utf8)

            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                guard let responseData = data, error == nil, let httpResponse = response as? HTTPURLResponse else {
                    if let error = error {
                        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
                        systemError(responseError)
                    } else {
                        let responseError = ResponseError(message: "Unexpected error.", statusCode: nil, responseBody: nil, systemError: nil)
                        systemError(responseError)
                    }

                    return
                }

                switch httpResponse.statusCode {
                case 200:
                    let result = SendContactOrderResponse(status: .SUCCESS)
                    onSuccess(result)
                default:
                    let responseBody = String(decoding: responseData, as: UTF8.self)
                    let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                    logicError(responseError)
                }
            }).resume()
        }
    }
    
    private func getSendContactOrderRequestsJSON(sendContactOrderRequests: [SendContactOrderRequest]) -> String {
        var sendContactOrdersArrayJSON = [String]()
        
        sendContactOrderRequests.forEach { sendContactOrderRequest in
            let orderJSON = self.getOrderJSON(order: sendContactOrderRequest.order)
            
            let rootContainer  = [
                "\"deviceId\": \"\(sendContactOrderRequest.deviceID)\"",
                "\"order\": \(orderJSON)"
            ]
            
            let stringJSON = "{ " + rootContainer.joined(separator: ", ") + " }"
            
            sendContactOrdersArrayJSON.append(stringJSON)
        }
        
        let sendContactOrderJSON = "[ " + sendContactOrdersArrayJSON.joined(separator: ", ") + " ]"
        
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
        
        return "{ " + orderContainer.joined(separator: ", ") + " }"
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
        
        return "{ " + addressContainer.joined(separator: ", ") + " }"
    }
    
}

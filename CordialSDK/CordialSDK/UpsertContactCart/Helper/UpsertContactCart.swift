//
//  UpsertContactCart.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/18/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class UpsertContactCart {
    
    func upsertContactCart(upsertContactCartRequest: UpsertContactCartRequest, onSuccess: @escaping (UpsertContactCartResponse) -> Void, systemError: @escaping (ResponseError) -> Void, logicError: @escaping (ResponseError) -> Void) -> Void {
        if let url = URL(string: CordialApiEndpoints().getСontactСartURL()) {
            var request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .POST)
            
            let upsertContactCartJSON = getUpsertContactCartJSON(upsertContactCartRequest: upsertContactCartRequest)
            request.httpBody = upsertContactCartJSON.data(using: .utf8)
            
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
                    let result = UpsertContactCartResponse(status: .SUCCESS)
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
    
    private func getUpsertContactCartJSON(upsertContactCartRequest: UpsertContactCartRequest) -> String {
        let cartItemsJSON = self.getCartItemsJSON(cartItems: upsertContactCartRequest.cartItems)
        
        var rootContainer  = [
            "\"deviceId\": \"\(upsertContactCartRequest.deviceID)\"",
            "\"cartitems\": \(cartItemsJSON)"
        ]
        
        if let primaryKey = upsertContactCartRequest.primaryKey {
            rootContainer.append("\"primaryKey\": \"\(primaryKey)\"")
        }
        
        let upsertContactCartJSON = "[ { " + rootContainer.joined(separator: ", ") + " } ]"
        
        return upsertContactCartJSON
    }
    
    func getCartItemsJSON(cartItems: [CartItem]) -> String {

        var cartItemsJSON = String()
        var cartItemsContainer = [String]()
        cartItems.forEach({ cartItem in
            var cartItemJSON = String()
            var cartItemContainer = [String]()
            cartItemContainer.append("\"productID\": \"\(cartItem.productID)\"")
            cartItemContainer.append("\"name\": \"\(cartItem.name)\"")
            cartItemContainer.append("\"sku\": \"\(cartItem.sku)\"")
            cartItemContainer.append("\"timestamp\": \"\(cartItem.timestamp)\"")
            
            if let category = cartItem.category {
                cartItemContainer.append("\"category\": \"\(category)\"")
            }
            
            if let url = cartItem.url {
                cartItemContainer.append("\"url\": \"\(url)\"")
            }
            
            if let itemDescription = cartItem.itemDescription {
                cartItemContainer.append("\"url\": \"\(itemDescription)\"")
            }
            
            if let qty = cartItem.qty {
                cartItemContainer.append("\"url\": \"\(qty)\"")
            }
            
            if let itemPrice = cartItem.itemPrice {
                cartItemContainer.append("\"url\": \"\(itemPrice)\"")
            }
            
            if let salePrice = cartItem.salePrice {
                cartItemContainer.append("\"url\": \"\(salePrice)\"")
            }
            
            if let attr = cartItem.attr {
                cartItemContainer.append("\"attr\": \(API.getDictionaryJSON(stringDictionary: attr))")
            }
            
            if let images = cartItem.images {
                cartItemContainer.append("\"images\": \(API.getStringArrayJSON(stringArray: images))")
            }
            
            if let properties = cartItem.properties {
                cartItemContainer.append("\"properties\": \(API.getDictionaryJSON(stringDictionary: properties))")
            }
            
            cartItemJSON = "{ " + cartItemContainer.joined(separator: ", ") + " }"
            
            cartItemsContainer.append(cartItemJSON)
        })
        cartItemsJSON = "[ " + cartItemsContainer.joined(separator: ", ") + " ]"
        
        return cartItemsJSON
    }
    
}

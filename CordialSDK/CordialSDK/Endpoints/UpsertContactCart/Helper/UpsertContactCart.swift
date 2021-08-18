//
//  UpsertContactCart.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/18/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class UpsertContactCart {
    
    let cordialAPI = CordialAPI()
    let internalCordialAPI = InternalCordialAPI()
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    func upsertContactCart(upsertContactCartRequest: UpsertContactCartRequest) {
        if let url = URL(string: CordialApiEndpoints().getContactCartURL()) {
            var request = CordialRequestFactory().getCordialURLRequest(url: url, httpMethod: .POST)
            
            let upsertContactCartJSON = getUpsertContactCartJSON(upsertContactCartRequest: upsertContactCartRequest)
            request.httpBody = upsertContactCartJSON.data(using: .utf8)
            
            let downloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
            
            let upsertContactCartURLSessionData = UpsertContactCartURLSessionData(upsertContactCartRequest: upsertContactCartRequest)
            let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_UPSERT_CONTACT_CART, taskData: upsertContactCartURLSessionData)
            CordialURLSession.shared.setOperation(taskIdentifier: downloadTask.taskIdentifier, data: cordialURLSessionData)
            
            self.requestSender.sendRequest(task: downloadTask)
        }
    }
    
    func getUpsertContactCartJSON(upsertContactCartRequest: UpsertContactCartRequest) -> String {
        let cartItemsJSON = self.getCartItemsJSON(cartItems: upsertContactCartRequest.cartItems)
        
        var rootContainer  = [
            "\"deviceId\": \"\(self.internalCordialAPI.getDeviceIdentifier())\"",
            "\"cartitems\": \(cartItemsJSON)"
        ]
        
        if let primaryKey = self.cordialAPI.getContactPrimaryKey() {
            rootContainer.append("\"primaryKey\": \"\(primaryKey)\"")
        }
        
        let rootContainerString = rootContainer.joined(separator: ", ")
        
        let upsertContactCartJSON = "[ { \(rootContainerString) } ]"
        
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
            cartItemContainer.append("\"category\": \"\(cartItem.category)\"")
            cartItemContainer.append("\"qty\": \(cartItem.qty)")
            cartItemContainer.append("\"timestamp\": \"\(cartItem.timestamp)\"")
            
            if let url = cartItem.url {
                cartItemContainer.append("\"url\": \"\(url)\"")
            }
            
            if let itemDescription = cartItem.itemDescription {
                cartItemContainer.append("\"description\": \"\(itemDescription)\"")
            }
            
            if let itemPrice = cartItem.itemPrice {
                cartItemContainer.append("\"itemPrice\": \(itemPrice)")
            }
            
            if let salePrice = cartItem.salePrice {
                cartItemContainer.append("\"salePrice\": \(salePrice)")
            }
            
            if let attr = cartItem.attr {
                cartItemContainer.append("\"attr\": \(API.getDictionaryJSON(attr))")
            }
            
            if let images = cartItem.images {
                cartItemContainer.append("\"images\": \(API.getArrayJSON(images))")
            }
            
            if let properties = cartItem.properties {
                cartItemContainer.append("\"properties\": \(API.getDictionaryJSON(properties))")
            }
            
            let cartItemContainerString = cartItemContainer.joined(separator: ", ")
            
            cartItemJSON = "{ \(cartItemContainerString) }"
            
            cartItemsContainer.append(cartItemJSON)
        })
        
        let cartItemsContainerString = cartItemsContainer.joined(separator: ", ")
        
        cartItemsJSON = "[ \(cartItemsContainerString) ]"
        
        return cartItemsJSON
    }
    
}

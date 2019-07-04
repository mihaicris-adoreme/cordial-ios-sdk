//
//  InAppMessage.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/3/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class InAppMessage {
    
    func getInAppMessage(mcID: String, onSuccess: @escaping (String) -> Void, systemError: @escaping (ResponseError) -> Void, logicError: @escaping (ResponseError) -> Void) -> Void {
        if let url = URL(string: CordialApiEndpoints().getInAppMessageURL(mcID: mcID)) {
            let request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .GET)
            
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
                    onSuccess("")
                case 404: // tmp logic
                    let html = "<body style='background-color: lightblue;'><button style='height:100px; width:100px; font-size: large;' onclick=\"buttonAction('https://tjs.cordialdev.com/prep-tj1.html')\">Click Here</button><button style='position: absolute; top: 0px; right: 0px; height:100px; width:100px; font-size: large;' onclick=\"buttonAction()\">Close</button></body>"
                    onSuccess(html)
                default:
                    let responseBody = String(decoding: responseData, as: UTF8.self)
                    let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                    logicError(responseError)
                }
            }).resume()
        }
    }

}

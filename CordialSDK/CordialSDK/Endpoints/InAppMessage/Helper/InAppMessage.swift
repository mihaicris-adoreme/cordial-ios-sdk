//
//  InAppMessage.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/3/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class InAppMessage {
    
    func getInAppMessage(mcID: String, onSuccess: @escaping (InAppMessageData) -> Void, systemError: @escaping (ResponseError) -> Void, logicError: @escaping (ResponseError) -> Void) -> Void {
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
                    let inAppMessageData = InAppMessageData(mcID: mcID, html: "", type: InAppMessageType.modal, top: 30, right: 30, bottom: 30, left: 30)
                    onSuccess(inAppMessageData)
                case 404: // tmp logic
                    let html = "<style type='text/css'>" +
                                    ".simple_button { color: #fff; text-transform: uppercase; background: #60a3bc; padding: 20px; display: inline-block; border: none; }" +
                                    ".product_button { font-size: 600%; margin-top: 50px !important; }" +
                                    ".dismiss_button { font-size: 500%; margin-top: 50px !important; }" +
                                    ".inner { display: table; margin: 0 auto; }" +
                                    ".outer { width:100% }" +
                                    ".text { font-size: 600%; margin-top: 50px !important; }" +
                               "</style>" +
                               "<body style='margin: auto;'>" +
                               "<img style='width:100%; height: auto; object-fit: contain; margin-top: 50px;' title='Alix Long Sleeve Woven Shirt' alt='Robert Graham'  src='data:image/jpeg;base64,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'>" +
                                    "<div class='outer'>" +
                                        "<p class='inner text'>DISCOUNT 20%</p>" +
                                        "<div class='inner simple_button product_button' onclick=\"buttonAction('https://tjs.cordialdev.com/prep-tj1.html', 'in_app_message_event_name')\">GO TO PRODUCT</div>" +
                                        "<div class='inner simple_button dismiss_button' onclick=\"buttonAction()\">DISMISS</div>" +
                                    "</div>" +
                               "</body>"
                    let top = 20
                    let right = 15
                    let bottom = 20
                    let left = 15
//                    let type = InAppMessageType.modal
                    let type = InAppMessageType.banner
                    let inAppMessageData = InAppMessageData(mcID: mcID, html: html, type: type, top: top, right: right, bottom: bottom, left: left)
                    onSuccess(inAppMessageData)
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

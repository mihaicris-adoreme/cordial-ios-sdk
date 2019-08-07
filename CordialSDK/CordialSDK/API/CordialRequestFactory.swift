//
//  CordialRequestFactory
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit

class CordialRequestFactory {

    let cordialAPI = CordialAPI()
    
    enum HttpMethods: String {
        case GET
        case POST
    }

    func getURLRequest(url: URL, httpMethod: HttpMethods) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.httpMethod = httpMethod.rawValue

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")  
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let userAgent = UserAgentBuilder().getUserAgent()
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let accountKey = cordialAPI.getAccountKey()
        request.setValue(accountKey, forHTTPHeaderField: "Cordial-AccountKey")
        
        let channelKey = cordialAPI.getChannelKey()
        request.setValue(channelKey, forHTTPHeaderField: "Cordial-ChannelKey")
        
        if let JWT = InternalCordialAPI().getCurrentJWT() {
            let authorizationBearerSchema = "Bearer \(JWT)"
            request.setValue(authorizationBearerSchema, forHTTPHeaderField: "Authorization")
        }
        
        return request
    }

}

//
//  PushNotificationParserCarousel.swift
//  CordialAppExtensions
//
//  Created by Yan Malinovsky on 19.11.2022.
//  Copyright © 2022 Cordial Experience, Inc. All rights reserved.
//

import Foundation
import os.log

class PushNotificationParserCarousel {
    
    // MARK: Get push notification carousel
    
    func getPushNotificationCarouselsCurrentPayloadType(userInfo: [AnyHashable : Any]) -> [PushNotificationCarousel] {
        var carousels = [PushNotificationCarousel]()
        
        if let carousel = userInfo["carousel"] as? [AnyObject] {
            carousel.forEach { data in
                guard let carouselData = data as? [String: String] else { return }
                
                guard let imageURLString = carouselData["imageURL"] else { return }
                guard let imageURL = URL(string: imageURLString) else {
                    os_log("CordialSDK_AppExtensions: Error [Image URL is not valid URL]", log: .default, type: .error)
                    return
                }
                
                guard let deepLinkString = carouselData["deepLink"] else { return }
                guard let deepLink = URL(string: deepLinkString) else {
                    os_log("CordialSDK_AppExtensions: Error [DeepLink URL is not valid URL]", log: .default, type: .error)
                    return
                }
                
                let carousel = PushNotificationCarousel(imageURL: imageURL, deepLink: deepLink)
                carousels.append(carousel)
            }
        }
        
        return carousels
    }
}

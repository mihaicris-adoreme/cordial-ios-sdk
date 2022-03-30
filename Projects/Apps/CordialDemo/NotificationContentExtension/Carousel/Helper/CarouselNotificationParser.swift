//
//  CarouselNotificationParser.swift
//  NotificationContentExtension
//
//  Created by Yan Malinovsky on 22.03.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation
import os.log

class CarouselNotificationParser {
    
    static func getCarousels(userInfo: [AnyHashable : Any]) -> [Carousel] {
        var carousels = [Carousel]()
        
        if let carousel = userInfo["carousel"] as? [AnyObject] {
            carousel.forEach { data in
                guard let carouselData = data as? [String: String] else { return }
                
                guard let imageURLString = carouselData["imageURL"] else { return }
                guard let imageURL = URL(string: imageURLString) else {
                    os_log("Image URL is not valid URL")
                    return
                }
                
                guard let deepLinkString = carouselData["deepLink"] else { return }
                guard let deepLink = URL(string: deepLinkString) else {
                    os_log("DeepLink URL is not valid URL")
                    return
                }
                
                let carousel = Carousel(imageURL: imageURL, deepLink: deepLink)
                carousels.append(carousel)
            }
        }
        
        return carousels
    }
    
}

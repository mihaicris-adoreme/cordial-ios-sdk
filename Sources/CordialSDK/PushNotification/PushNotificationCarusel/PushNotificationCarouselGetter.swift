//
//  PushNotificationCarouselGetter.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 16.11.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation
import os.log

class PushNotificationCarouselGetter {
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    func preparePushNotificationCarousel(mcID: String, carousel: PushNotificationCarousel) {
        let request = CordialRequestFactory().getBaseURLRequest(url: carousel.imageURL, httpMethod: .GET)
        
        let downloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
        
        let pushNotificationCarouselURLSessionData = PushNotificationCarouselURLSessionData(mcID: mcID, carousel: carousel)
        let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_PUSH_NOTIFICATION_CAROUSEL, taskData: pushNotificationCarouselURLSessionData)
        CordialURLSession.shared.setOperation(taskIdentifier: downloadTask.taskIdentifier, data: cordialURLSessionData)
        
        self.requestSender.sendRequest(task: downloadTask)
    }
    
    func completionHandler(pushNotificationCarouselURLSessionData: PushNotificationCarouselURLSessionData, statusCode: Int, imageData: Data) {
        
        switch statusCode {
        case 200:
            let mcID = pushNotificationCarouselURLSessionData.mcID
            let imageURL = pushNotificationCarouselURLSessionData.carousel.imageURL.absoluteString
            
            if var carousels = CordialGroupUserDefaults.dictionary(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_IMAGES) as? Dictionary<String, Dictionary<String, Data>> {
                
                if var carousel = carousels[mcID] {
                    carousel[imageURL] = imageData
                    
                    carousels[mcID] = carousel
                    
                    CordialGroupUserDefaults.set(carousels, forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_IMAGES)
                } else {
                    carousels[mcID] = [imageURL: imageData]
                    
                    CordialGroupUserDefaults.set(carousels, forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_IMAGES)
                }
            } else {
                let carousels = [mcID: [imageURL: imageData]]
                
                CordialGroupUserDefaults.set(carousels, forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_IMAGES)
            }
        default:
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Downloading push notification carousel image failed with URL: [%{public}@] Error [Image by the URL is absent]", log: OSLog.cordialPushNotificationCarousel, type: .error, pushNotificationCarouselURLSessionData.carousel.imageURL.absoluteString)
            }
        }
    }
    
    func errorHandler(pushNotificationCarouselURLSessionData: PushNotificationCarouselURLSessionData, error: Error) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("Downloading push notification carousel image failed with URL: [%{public}@] Error: [%{public}@]", log: OSLog.cordialPushNotificationCarousel, type: .error, pushNotificationCarouselURLSessionData.carousel.imageURL.absoluteString, error.localizedDescription)
        }
    }
}

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
        let request = CordialRequestFactory().getCordialURLRequest(url: carousel.imageURL, httpMethod: .GET)
        
        let downloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
        
        let pushNotificationCarouselURLSessionData = PushNotificationCarouselURLSessionData(mcID: mcID, carousel: carousel)
        let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_PUSH_NOTIFICATION_CAROUSEL, taskData: pushNotificationCarouselURLSessionData)
        CordialURLSession.shared.setOperation(taskIdentifier: downloadTask.taskIdentifier, data: cordialURLSessionData)
        
        self.requestSender.sendRequest(task: downloadTask)
    }
    
    func completionHandler(pushNotificationCarouselURLSessionData: PushNotificationCarouselURLSessionData, statusCode: Int, responseBody: String) {
        // TODO
    }
    
    func errorHandler(pushNotificationCarouselURLSessionData: PushNotificationCarouselURLSessionData, error: Error) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Downloading push notification carousel image failed with URL: [%{public}@] Error: [%{public}@]", log: OSLog.cordialPushNotificationCarousel, type: .info, pushNotificationCarouselURLSessionData.carousel.imageURL.absoluteString, error.localizedDescription)
        }
    }
}

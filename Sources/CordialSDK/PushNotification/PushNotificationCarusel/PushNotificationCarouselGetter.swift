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
        
        let pushNotificationCarouselURLSessionData = PushNotificationCarouselURLSessionData(mcID: mcID)
        let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_PUSH_NOTIFICATION_CAROUSEL, taskData: pushNotificationCarouselURLSessionData)
        CordialURLSession.shared.setOperation(taskIdentifier: downloadTask.taskIdentifier, data: cordialURLSessionData)
        
        self.requestSender.sendRequest(task: downloadTask)
    }
    
    func completionHandler(mcID: String, pushNotificationCarouselData: PushNotificationCarouselData) {
        // TODO
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Push notification carousel image has been successfully download with mcID: [%{public}@]", log: OSLog.cordialPushNotificationCarousel, type: .info, mcID)
        }
    }
    
    func errorHandler(mcID: String, error: ResponseError) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Downloading push notification carousel image failed with mcID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialPushNotificationCarousel, type: .info, mcID, error.message)
        }
    }
}

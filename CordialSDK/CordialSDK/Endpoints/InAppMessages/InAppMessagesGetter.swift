//
//  InAppMessagesGetter.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 11.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

class InAppMessagesGetter {
    
    let inAppMessage = InAppMessage()
    let inAppMessageGetter = InAppMessageGetter()
    
    func setInAppMessagesParamsToCoreData(messages: [Dictionary<String, AnyObject>]) {
        for message in messages {
            guard let mcID = message["_id"] as? String else { continue }
            guard let sentAt = message["sentAt"] as? String else { continue }
            
            // TODO
//                guard let url = message["url"] as? String else { continue }
//                guard let urlExpireAt = message["urlExpireAt"] as? String else { continue }
            
            let typeString = self.inAppMessage.getTypeIAM(payload: message)
            let displayTypeString = self.inAppMessage.getDisplayTypeIAM(payload: message)
            let inactiveSessionDisplayString = self.inAppMessage.getInactiveSessionDisplayIAM(payload: message)
            
            let type = self.inAppMessageGetter.getInAppMessageType(typeString: typeString)
            let displayType = self.inAppMessageGetter.getInAppMessageDisplayType(displayTypeString: displayTypeString)
            let inactiveSessionDisplay = self.inAppMessageGetter.getInAppMessageInactiveSessionDisplayType(inactiveSessionDisplayString: inactiveSessionDisplayString)
            
            var (height, top, right, bottom, left) = self.inAppMessageGetter.InAppMessageOptionalParamsDefaultValues()
            var expirationTime: Date?
            
            if let bannerHeight = self.inAppMessage.getBannerHeightIAM(payload: message) {
                height = bannerHeight
            }
            
            if let modalTopMargin = self.inAppMessage.getModalTopMarginIAM(payload: message) {
                top = modalTopMargin
            }
            
            if let modalRightMargin = self.inAppMessage.getModalRightMarginIAM(payload: message) {
                right = modalRightMargin
            }
            
            if let modalBottomMargin = self.inAppMessage.getModalBottomMarginIAM(payload: message) {
                bottom = modalBottomMargin
            }
            
            if let modalLeftMargin = self.inAppMessage.getModalLeftMarginIAM(payload: message) {
                left = modalLeftMargin
            }
            
            if let expirationTimeTimestamp = InAppMessage().getExpirationTimeIAM(payload: message) {
                expirationTime = CordialDateFormatter().getDateFromTimestamp(timestamp: expirationTimeTimestamp)
            }
            
            let inAppMessageParams = InAppMessageParams(mcID: mcID, date: Date(), type: type, height: height, top: top, right: right, bottom: bottom, left: left, displayType: displayType, expirationTime: expirationTime, inactiveSessionDisplay: inactiveSessionDisplay)
            
            CoreDataManager.shared.inAppMessagesParam.setParamsToCoreDataInAppMessagesParam(inAppMessageParams: inAppMessageParams)
            CoreDataManager.shared.inAppMessagesQueue.setMcIdToCoreDataInAppMessagesQueue(mcID: mcID)
        }
        
        InAppMessagesQueueManager().fetchInAppMessagesFromQueue()
    }
    
}

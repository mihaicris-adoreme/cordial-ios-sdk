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
    
    func startFetchInAppMessages(isSilentPushDeliveryEvent: Bool) {
        if isSilentPushDeliveryEvent {
            InAppMessages.shared.updateIfNeeded()
        } else if let contactTimestamp = CoreDataManager.shared.contactTimestampsURL.getContactTimestampFromCoreData(),
           API.isValidExpirationDate(date: contactTimestamp.expireDate) {
            
            ContactTimestampURL.shared.updateIfNeeded(contactTimestamp.url)
        } else {
            ContactTimestamps.shared.updateIfNeeded()
        }
    }
    
    func setInAppMessagesParamsToCoreData(messages: [Dictionary<String, AnyObject>]) {
        let cordialDateFormatter = CordialDateFormatter()
        
        var inAppMessageContents = [InAppMessageContent]()
        var inAppMessagesParams = [InAppMessageParams]()
        var mcIDs = [String]()
        
        for message in messages {
            guard let mcID = message["_id"] as? String else { continue }
            
            guard let sentAtTimestamp = message["sentAt"] as? String else { continue }
            guard let sentAt = cordialDateFormatter.getDateFromTimestamp(timestamp: sentAtTimestamp) else { continue }
            self.inAppMessage.prepareAndSaveTheLatestSentAtInAppMessageDate(sentAt: sentAt)
            
            guard let contentURLString = message["url"] as? String else { continue }
            guard let contentURLExpireAtTimestamp = message["urlExpireAt"] as? String else { continue }
            
            guard let contentURL = URL(string: contentURLString) else { continue }
            guard let contentURLExpireAt = cordialDateFormatter.getDateFromTimestamp(timestamp: contentURLExpireAtTimestamp) else { continue }
            
            let inAppMessageContent = InAppMessageContent(mcID: mcID, url: contentURL, expireDate: contentURLExpireAt)
            inAppMessageContents.append(inAppMessageContent)
            
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
            
            if let expirationTimeTimestamp = self.inAppMessage.getExpirationTimeIAM(payload: message) {
                expirationTime = cordialDateFormatter.getDateFromTimestamp(timestamp: expirationTimeTimestamp)
            }
            
            let inAppMessageParams = InAppMessageParams(mcID: mcID, date: Date(), type: type, height: height, top: top, right: right, bottom: bottom, left: left, displayType: displayType, expirationTime: expirationTime, inactiveSessionDisplay: inactiveSessionDisplay)
            
            inAppMessagesParams.append(inAppMessageParams)
            mcIDs.append(mcID)
        }
        
        DispatchQueue.main.async {
            inAppMessageContents.forEach { inAppMessageContent in
                CoreDataManager.shared.inAppMessageContentURL.putInAppMessageContentToCoreData(inAppMessageContent: inAppMessageContent)
            }
            
            CoreDataManager.shared.inAppMessagesParam.setParamsToCoreDataInAppMessagesParam(inAppMessagesParams: inAppMessagesParams)
            
            CoreDataManager.shared.inAppMessagesQueue.setMcIDsToCoreDataInAppMessagesQueue(mcIDs: mcIDs)

            DispatchQueue.main.async {
                InAppMessagesQueueManager().fetchInAppMessageDataFromQueue()
            }
        }
    }
    
}

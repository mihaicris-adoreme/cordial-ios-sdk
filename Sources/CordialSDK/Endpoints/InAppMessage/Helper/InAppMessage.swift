//
//  InAppMessage.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/3/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit

class InAppMessage {
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    func getInAppMessage(mcID: String) {
        if let url = URL(string: CordialApiEndpoints().getInAppMessageURL(mcID: mcID)) {
            let request = CordialRequestFactory().getCordialURLRequest(url: url, httpMethod: .GET)
            
            let downloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
            
            let inAppMessageURLSessionData = InAppMessageURLSessionData(mcID: mcID)
            let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE, taskData: inAppMessageURLSessionData)
            CordialURLSession.shared.setOperation(taskIdentifier: downloadTask.taskIdentifier, data: cordialURLSessionData)
            
            self.requestSender.sendRequest(task: downloadTask)
        }
    }
    
    // MARK: Prepare and show IAM
    
    func prepareAndShowInAppMessage(inAppMessageData: InAppMessageData) {
        CoreDataManager.shared.inAppMessagesCache.putInAppMessageData(inAppMessageData: inAppMessageData)
        
        InAppMessagesQueueManager().fetchInAppMessageDataFromQueue()
        
        if !InAppMessageProcess.shared.isPresentedInAppMessage {
            DispatchQueue.main.async {
                if UIApplication.shared.applicationState == .active {
                    switch inAppMessageData.displayType {
                    case InAppMessageDisplayType.displayOnAppOpenEvent:
                        LoggerManager.shared.info(message: "IAM: [Display on next app open]. Save \(inAppMessageData.type.rawValue) IAM with mcID: [\(inAppMessageData.mcID)]", category: "CordialSDKInAppMessage")
                    case InAppMessageDisplayType.displayImmediately:
                        if InAppMessageProcess.shared.isAvailableInAppMessage(inAppMessageData: inAppMessageData) {
                            InAppMessageProcess.shared.showInAppMessage(inAppMessageData: inAppMessageData)
                        } else {
                            InAppMessageProcess.shared.removeInAppMessageFromCoreData(mcID: inAppMessageData.mcID)
                            
                            LoggerManager.shared.info(message: "Failed showing \(inAppMessageData.type.rawValue) IAM with mcID: [\(inAppMessageData.mcID)]. Error: [Live time has expired]", category: "CordialSDKInAppMessage")
                        }
                    }
                } else {
                    LoggerManager.shared.info(message: "IAM: [App is not on foreground]. Save \(inAppMessageData.type.rawValue) IAM with mcID: [\(inAppMessageData.mcID)]", category: "CordialSDKInAppMessage")
                }
            }
        }
    }
    
    // MARK: Get IAM data
    
    func getInAppMessageData(inAppMessageParams: InAppMessageParams, html: String) -> InAppMessageData {
        let mcID = inAppMessageParams.mcID
        let type = inAppMessageParams.type
        let displayType = inAppMessageParams.displayType
        let expirationTime = inAppMessageParams.expirationTime
        
        switch type {
        case InAppMessageType.fullscreen:
            let top = 0
            let right = 0
            let bottom = 0
            let left = 0
            
            return InAppMessageData(mcID: mcID, html: html, type: type, displayType: displayType, top: top, right: right, bottom: bottom, left: left, expirationTime: expirationTime)
        default:
            let top = Int(inAppMessageParams.top)
            let right = Int(inAppMessageParams.right)
            let bottom = Int(inAppMessageParams.bottom)
            let left = Int(inAppMessageParams.left)
            
            return InAppMessageData(mcID: mcID, html: html, type: type, displayType: displayType, top: top, right: right, bottom: bottom, left: left, expirationTime: expirationTime)
        }
    
    }
    
    // MARK: Prepare and save the latest sentAt IAM date
    
    func prepareAndSaveTheLatestSentAtInAppMessageDate(sentAt: Date) {
        let internalCordialAPI = InternalCordialAPI()
        let cordialDateFormatter = CordialDateFormatter()
        
        let sentAtTimestamp = cordialDateFormatter.getTimestampFromDate(date: sentAt)
        guard let previousSentAtTimestamp = internalCordialAPI.getTheLatestSentAtInAppMessageDate() else {
            self.initTheLatestSentAtInAppMessageDate()
            
            return
        }
        
        if let previousSentAt = cordialDateFormatter.getDateFromTimestamp(timestamp: previousSentAtTimestamp),
           sentAt.timeIntervalSince1970 > previousSentAt.timeIntervalSince1970 {
            
            internalCordialAPI.setTheLatestSentAtInAppMessageDate(sentAtTimestamp: sentAtTimestamp)
        }
        
    }
    
    // MARK: Init the latest sentAt IAM date
    
    func initTheLatestSentAtInAppMessageDate() {
        let cordialDateFormatter = CordialDateFormatter()
        let currentTimestamp = cordialDateFormatter.getCurrentTimestamp()
        guard let currentDate = cordialDateFormatter.getDateFromTimestamp(timestamp: currentTimestamp) else { return }
        let currentDateMinusOneMinute = currentDate.adding(minutes: -1)
        let currentTimestampMinusOneMinute = cordialDateFormatter.getTimestampFromDate(date: currentDateMinusOneMinute)
        
        InternalCordialAPI().setTheLatestSentAtInAppMessageDate(sentAtTimestamp: currentTimestampMinusOneMinute)
    }
    
    // MARK: Get in app message params
    
    func getTypeIAM(payload: [String: AnyObject]) -> String? {
        if let typeIAM = payload["type"] as? String {
            return typeIAM
        }
        
        return nil
    }
    
    func getDisplayTypeIAM(payload: [String: AnyObject]) -> String? {
        if let displayTypeIAM = payload["displayType"] as? String {
            return displayTypeIAM
        }
        
        return nil
    }
    
    func getInactiveSessionDisplayIAM(payload: [String: AnyObject]) -> String? {
        if let inactiveSessionDisplayString = payload["inactiveSessionDisplay"] as? String {
            return inactiveSessionDisplayString
        }
        
        return nil
    }
    
    func getExpirationTimeIAM(payload: [String: AnyObject]) -> String? {
        if let expirationTime = payload["expirationTime"] as? String {
            return expirationTime
        }
        
        return nil
    }
    
    func getModalRightMarginIAM(payload: [String: AnyObject]) -> Int16? {
        if let right = payload["right"] as? Int16 {
            return right
        }
        
        return nil
    }
    
    func getModalLeftMarginIAM(payload: [String: AnyObject]) -> Int16? {
        if let left = payload["left"] as? Int16 {
            return left
        }
        
        return nil
    }

}

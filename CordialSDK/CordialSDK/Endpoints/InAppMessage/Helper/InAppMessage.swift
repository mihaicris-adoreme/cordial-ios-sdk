//
//  InAppMessage.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/3/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

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
    
    func getBannerHeightIAM(payload: [String: AnyObject]) -> Int16? {
        if let height = payload["height"] as? Int16 {
            return height
        }
        
        return nil
    }
    
    func getModalTopMarginIAM(payload: [String: AnyObject]) -> Int16? {
        if let top = payload["top"] as? Int16 {
            return top
        }
        
        return nil
    }
    
    func getModalRightMarginIAM(payload: [String: AnyObject]) -> Int16? {
        if let right = payload["right"] as? Int16 {
            return right
        }
        
        return nil
    }
    
    func getModalBottomMarginIAM(payload: [String: AnyObject]) -> Int16? {
        if let bottom = payload["bottom"] as? Int16 {
            return bottom
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

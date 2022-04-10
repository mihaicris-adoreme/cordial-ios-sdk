//
//  CordialNotificationServiceExtension.swift
//  CordialAppExtensions
//
//  Created by Yan Malinovsky on 5/12/19.
//  Copyright © 2019 Cordial Experience, Inc. All rights reserved.
//

import Foundation
import UserNotifications
import os.log

open class CordialNotificationServiceExtension: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    open override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            
            // Start
            
            var urlString:String? = nil
            if let imageURL = request.content.userInfo["imageURL"] as? String {
                os_log("CordialSDK_AppExtensions: Payload contains imageURL", log: .default, type: .info)
                urlString = imageURL
            } else {
                os_log("CordialSDK_AppExtensions: Payload does not contain imageURL", log: .default, type: .info)
            }
            
            if urlString != nil, let fileUrl = URL(string: urlString!) {
                guard let imageData = NSData(contentsOf: fileUrl) else {
                    os_log("CordialSDK_AppExtensions: Error downloading an image", log: .default, type: .error)
                    contentHandler(bestAttemptContent)
                    return
                }
                guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "image.gif", data: imageData, options: nil) else {
                    os_log("CordialSDK_AppExtensions: Error saving an image", log: .default, type: .error)
                    contentHandler(bestAttemptContent)
                    return
                }
                
                bestAttemptContent.attachments = [ attachment ]
                
                os_log("CordialSDK_AppExtensions: Image has been added successfully", log: .default, type: .info)
            } else {
                os_log("CordialSDK_AppExtensions: Error [imageURL isn’t a valid URL]", log: .default, type: .error)
            }
            
            // End
            
            contentHandler(bestAttemptContent)
        }
    }
    
    open override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            os_log("CordialSDK_AppExtensions: Image attaching failed by timeout", log: .default, type: .info)
            contentHandler(bestAttemptContent)
        }
    }
    
}

extension UNNotificationAttachment {
    
    static func saveImageToDisk(fileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL?.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL!, options: [])
            let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL!, options: options)
            return attachment
        } catch let error {
            os_log("CordialSDK_AppExtensions: Error [%{public}@]", log: .default, type: .error, error.localizedDescription)
        }
        
        return nil
    }
}

//
//  App.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 3/20/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import UIKit
import CordialSDK

struct App {
    
    static private let USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN = "USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN"
    
    static private let USER_DEFAULTS_KEY_FOR_SAVE_SETTINGS_TYPE = "USER_DEFAULTS_KEY_FOR_SAVE_SETTINGS_TYPE"
    
    static private let USER_DEFAULTS_KEY_FOR_EVENTS_STREAM_URL = "USER_DEFAULTS_KEY_FOR_EVENTS_STREAM_URL"
    static private let USER_DEFAULTS_KEY_FOR_MESSAGE_HUB_URL = "USER_DEFAULTS_KEY_FOR_MESSAGE_HUB_URL"
    static private let USER_DEFAULTS_KEY_FOR_ACCOUNT_KEY = "USER_DEFAULTS_KEY_FOR_ACCOUNT_KEY"
    static private let USER_DEFAULTS_KEY_FOR_CHANNEL_KEY = "USER_DEFAULTS_KEY_FOR_CHANNEL_KEY"
    static private let USER_DEFAULTS_KEY_FOR_IS_EDUCATIONAL_NOTIFICATION_CATEGORIES = "USER_DEFAULTS_KEY_FOR_IS_EDUCATIONAL_NOTIFICATION_CATEGORIES"
    
    static let DEFAULT_UNARCHIVER_CLASSES = [NSData.self, NSArray.self, NSDictionary.self, NSString.self, NSDate.self, NSNumber.self, NSURL.self]
     
    // MARK: CordialSDK - Get Init Params
    
    static func getCordialSDKInitParams() -> (String, String, String, String) {
        var accountKey = "qc-all-channels-cID-pk"
        if !self.getAccountKey().isEmpty {
            accountKey = self.getAccountKey()
        }
        
        var channelKey = "push"
        if !self.getChannelKey().isEmpty {
            channelKey = self.getChannelKey()
        }
        
        var eventsStreamURL = String()
        if !self.getEventsStreamURL().isEmpty {
            eventsStreamURL = self.getEventsStreamURL()
        }
        
        var messageHubURL = String()
        if !self.getMessageHubURL().isEmpty {
            messageHubURL = self.getMessageHubURL()
        }
        
        return (accountKey, channelKey, eventsStreamURL, messageHubURL)
    }
    
    // MARK: CordialSDK - Account Key
    
    static private func getAccountKey() -> String {
        if let accountKey = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEY_FOR_ACCOUNT_KEY) {
            return accountKey
        }
        
        return CordialAPI().getAccountKey()
    }
    
    static func setAccountKey(accountKey: String) {
        UserDefaults.standard.set(accountKey, forKey: USER_DEFAULTS_KEY_FOR_ACCOUNT_KEY)
    }
    
    // MARK: CordialSDK - Channel Key
    
    static private func getChannelKey() -> String {
        if let channelKey = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEY_FOR_CHANNEL_KEY) {
            return channelKey
        }
        
        return CordialAPI().getChannelKey()
    }
    
    static func setChannelKey(channelKey: String) {
        UserDefaults.standard.set(channelKey, forKey: USER_DEFAULTS_KEY_FOR_CHANNEL_KEY)
    }
    
    // MARK: CordialSDK - Events Stream URL
    
    static private func getEventsStreamURL() -> String {
        if let eventsStreamURL = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEY_FOR_EVENTS_STREAM_URL) {
            return eventsStreamURL
        }
        
        return CordialAPI().getEventsStreamURL()
    }
    
    static func setEventsStreamURL(eventsStreamURL: String) {
        UserDefaults.standard.set(eventsStreamURL, forKey: USER_DEFAULTS_KEY_FOR_EVENTS_STREAM_URL)
    }
    
    // MARK: CordialSDK - Message Hub URL
    
    static private func getMessageHubURL() -> String {
        if let messageHubURL = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEY_FOR_MESSAGE_HUB_URL) {
            return messageHubURL
        }
        
        return CordialAPI().getMessageHubURL()
    }
    
    static func setMessageHubURL(messageHubURL: String) {
        UserDefaults.standard.set(messageHubURL, forKey: USER_DEFAULTS_KEY_FOR_MESSAGE_HUB_URL)
    }
    
    static func getNotificationCategoriesIsEducational() -> Bool {
        return UserDefaults.standard.bool(forKey: USER_DEFAULTS_KEY_FOR_IS_EDUCATIONAL_NOTIFICATION_CATEGORIES)
    }
    
    static func setNotificationCategoriesIsEducational(_ isEducational: Bool) {
        UserDefaults.standard.set(isEducational, forKey: USER_DEFAULTS_KEY_FOR_IS_EDUCATIONAL_NOTIFICATION_CATEGORIES)
    }
    
    // MARK: App
    
    static func getInboxMessageMetadata(inboxMessage: InboxMessage) -> String? {
        var metadata: [String: String] = [
            "title": "[No title provided]",
            "subtitle": "[No subtitle provided]",
            "imageUrl": "https://i.imgur.com/bhjRMtD.png"
        ]
        
        if let inboxMessageMetadata = inboxMessage.metadata,
           let inboxMessageMetadataData = inboxMessageMetadata.data(using: .utf8),
           let inboxMessageMetadataJSON = try? JSONSerialization.jsonObject(with: inboxMessageMetadataData, options: []) as? [String: String] {
            
            for (key, data) in inboxMessageMetadataJSON {
                metadata[key] = data
            }
        }
        
        var metadataContainer: [String] = []
        for (key, data) in metadata {
            metadataContainer.append("\"\(key)\": \"\(data)\"")
        }
        
        return "{ \(metadataContainer.joined(separator: ", ")) }"
    }
    
    static func cancelTask(_ url: URL) {
        URLSession.shared.getAllTasks { tasks in
            tasks.filter { $0.state == .running }
                 .filter { $0.originalRequest?.url == url }.first?
                 .cancel()
        }
    }
    
    static func isUserLogIn() -> Bool {
        return UserDefaults.standard.bool(forKey: USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN)
    }
    
    static func userLogIn() {
        UserDefaults.standard.set(true, forKey: USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN)
    }
    
    static func userLogOut() {
        UserDefaults.standard.set(false, forKey: USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN)
    }
    
    static func setSettingsType(settingsType: String) {
        UserDefaults.standard.set(settingsType, forKey: USER_DEFAULTS_KEY_FOR_SAVE_SETTINGS_TYPE)
    }
    
    static func getSettingsType() -> String {
        switch UserDefaults.standard.string(forKey: USER_DEFAULTS_KEY_FOR_SAVE_SETTINGS_TYPE) {
        case Settings.qc.rawValue:
            return Settings.qc.rawValue
        case Settings.staging.rawValue:
            return Settings.staging.rawValue
        case Settings.production.rawValue:
            return Settings.production.rawValue
        case Settings.usWest2.rawValue:
            return Settings.usWest2.rawValue
        case Settings.custom.rawValue:
            return Settings.custom.rawValue
        default:
            return Settings.custom.rawValue
        }
    }
    
    static func popupSimpleNoteAlert(title: String?, message: String?, controller: UIViewController) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            alertController.addAction(okAction)
            
            controller.present(alertController, animated: true, completion: nil)
        }
    }

    static func getActiveViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.first( where: { $0.isKeyWindow } )
        
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            return topController
        }
        
        return nil
    }
}

extension UIApplication {
    var icon: UIImage? {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? NSDictionary,
            let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? NSDictionary,
            let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? NSArray,
            // First will be smallest for the device class, last will be the largest for device class
            let lastIcon = iconFiles.lastObject as? String,
            let icon = UIImage(named: lastIcon) else {
                return nil
        }

        return icon
    }
}

extension UITextField {
    func setBottomBorder(color: UIColor) {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

extension UIViewController {
    var previousViewController: UIViewController? {
        guard let navigationController = navigationController else { return nil }
        let count = navigationController.viewControllers.count
        return count < 1 ? nil : navigationController.viewControllers[count - 1]
    }
}

extension UIImageView {
    func asyncImage(url: URL) {
        self.image = nil
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let responseData = data {
                let jpegData = UIImage(data: responseData)?.jpegData(compressionQuality: 1)
                
                DispatchQueue.main.async {
                    if self.image == nil {
                        self.image = UIImage(data: jpegData ?? responseData)
                    }
                }
            } else {
                print("Image is absent by the URL")
            }
        }.resume()
    }
    
    func roundImage(borderWidth: CGFloat, borderColor: UIColor) {
        DispatchQueue.main.async {
            self.layer.borderWidth = borderWidth
            self.layer.masksToBounds = false
            self.layer.borderColor = borderColor.cgColor
            self.layer.cornerRadius = self.frame.height / 2
            self.clipsToBounds = true
        }
    }
}

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}

extension UIImage {
    func round(_ radius: CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        let result = renderer.image { c in
            let rounded = UIBezierPath(roundedRect: rect, cornerRadius: radius)
            rounded.addClip()
            if let cgImage = self.cgImage {
                UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation).draw(in: rect)
            }
        }
      
        return result
    }
    
    func circle() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        let result = renderer.image { c in
            let isPortrait = size.height > size.width
            let isLandscape = size.width > size.height
            let breadth = min(size.width, size.height)
            let breadthSize = CGSize(width: breadth, height: breadth)
            let breadthRect = CGRect(origin: .zero, size: breadthSize)
            let origin = CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0,
                                 y: isPortrait  ? floor((size.height - size.width) / 2) : 0)
            let circle = UIBezierPath(ovalIn: breadthRect)
            circle.addClip()
            if let cgImage = self.cgImage?.cropping(to: CGRect(origin: origin, size: breadthSize)) {
                UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation).draw(in: rect)
            }
        }
        
        return result
    }
}

extension UIView {
    func popIn(duration: TimeInterval = 0.5, completion: ((Bool) -> ())? = nil) {
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: duration, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseOut, animations: {
            self.alpha = 1
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: completion)
    }
    
    func popOut(duration: TimeInterval = 0.5, completion: ((Bool) -> ())? = nil) {
        UIView.animate(withDuration: duration, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseOut, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: completion)
    }
}

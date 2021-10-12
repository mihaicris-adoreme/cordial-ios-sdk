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
    
    static private let USER_DEFAULTS_KEY_FOR_IS_GUEST_USER = "USER_DEFAULTS_KEY_FOR_IS_GUEST_USER"
    
    static private let USER_DEFAULTS_KEY_FOR_SAVE_SETTINGS_TYPE = "USER_DEFAULTS_KEY_FOR_SAVE_SETTINGS_TYPE"
    
    static private let USER_DEFAULTS_KEY_FOR_EVENTS_STREAM_URL = "USER_DEFAULTS_KEY_FOR_EVENTS_STREAM_URL"
    static private let USER_DEFAULTS_KEY_FOR_MESSAGE_HUB_URL = "USER_DEFAULTS_KEY_FOR_MESSAGE_HUB_URL"
    static private let USER_DEFAULTS_KEY_FOR_ACCOUNT_KEY = "USER_DEFAULTS_KEY_FOR_ACCOUNT_KEY"
    static private let USER_DEFAULTS_KEY_FOR_CHANNEL_KEY = "USER_DEFAULTS_KEY_FOR_CHANNEL_KEY"
     
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
    
    // MARK: App
    
    static func getInboxMessageMetadata(inboxMessage: InboxMessage) -> String? {
        var inboxMessageMetadata = inboxMessage.metadata
        if inboxMessageMetadata == nil {
            inboxMessageMetadata = """
                        {
                          "title": "No title provided",
                          "subtitle": "No subtitle provided",
                          "imageUrl": "https://i.imgur.com/bhjRMtD.png"
                        }
                    """
        }
        
        return inboxMessageMetadata
    }
    
    static func isGuestUser() -> Bool {
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEY_FOR_IS_GUEST_USER) == nil {
            return true
        }
        
        return UserDefaults.standard.bool(forKey: USER_DEFAULTS_KEY_FOR_IS_GUEST_USER)
    }
    
    static func userLogIn() {
        UserDefaults.standard.set(false, forKey: USER_DEFAULTS_KEY_FOR_IS_GUEST_USER)
    }
    
    static func userLogOut() {
        UserDefaults.standard.set(true, forKey: USER_DEFAULTS_KEY_FOR_IS_GUEST_USER)
    }
    
    static func setSavedSettingsType(settingsType: String) {
        UserDefaults.standard.set(settingsType, forKey: USER_DEFAULTS_KEY_FOR_SAVE_SETTINGS_TYPE)
    }
    
    static func getSavedSettingsType() -> String {
        switch UserDefaults.standard.string(forKey: USER_DEFAULTS_KEY_FOR_SAVE_SETTINGS_TYPE) {
        case Settings.qc.rawValue:
            return Settings.qc.rawValue
        case Settings.staging.rawValue:
            return Settings.staging.rawValue
        case Settings.production.rawValue:
            return Settings.production.rawValue
        case Settings.custom.rawValue:
            return Settings.custom.rawValue
        default:
            return Settings.custom.rawValue
        }
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
    public func asyncImage(url: URL) {
        self.image = nil
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let responseData = data {
                DispatchQueue.main.async {
                    self.image = UIImage(data: responseData)
                }
            } else {
                print("Image is absent by the URL")
            }
        }.resume()
    }
    
    func roundImage(borderWidth: CGFloat, borderColor: UIColor) {
        self.layer.borderWidth = borderWidth
        self.layer.masksToBounds = false
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}

func popupSimpleNoteAlert(title: String?, message: String?, controller: UIViewController) {
    DispatchQueue.main.async {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(okAction)
        
        controller.present(alertController, animated: true, completion: nil)
    }
}

func getActiveViewController() -> UIViewController? {
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }

        return topController
    }
    
    return nil
}



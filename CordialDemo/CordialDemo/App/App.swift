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

extension AppDelegate {
    
    func setupCordialSDKLogicErrorHandler() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: .cordialSendCustomEventsLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .cordialSendCustomEventsLogicError, object: nil)
        
        notificationCenter.removeObserver(self, name: .cordialUpsertContactCartLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .cordialUpsertContactCartLogicError, object: nil)
        
        notificationCenter.removeObserver(self, name: .cordialSendContactOrdersLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .cordialSendContactOrdersLogicError, object: nil)
        
        notificationCenter.removeObserver(self, name: .cordialUpsertContactsLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .cordialUpsertContactsLogicError, object: nil)
        
        notificationCenter.removeObserver(self, name: .cordialSendContactLogoutLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .cordialSendContactLogoutLogicError, object: nil)
        
        notificationCenter.removeObserver(self, name: .cordialInAppMessageLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .cordialInAppMessageLogicError, object: nil)
        
        notificationCenter.removeObserver(self, name: .cordialInboxMessagesMarkReadUnreadLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .cordialInboxMessagesMarkReadUnreadLogicError, object: nil)
        
        notificationCenter.removeObserver(self, name: .cordialInboxMessageDeleteRequestLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .cordialInboxMessageDeleteRequestLogicError, object: nil)
        
    }
    
    @objc func cordialNotificationErrorHandler(notification: NSNotification) {
        if let error = notification.object as? ResponseError {
            CordialAPI().showSystemAlert(title: error.message, message: error.responseBody)
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



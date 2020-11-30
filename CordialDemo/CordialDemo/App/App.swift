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

extension UIView {
    func gradientView(size: CGSize, fromColor: UIColor, toColor: UIColor) {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [fromColor.cgColor, toColor.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)

        self.layer.insertSublayer(gradient, at: 0)
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



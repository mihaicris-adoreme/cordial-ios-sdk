//
//  LoginViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 3/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var baseURLTextField: UITextField!
    @IBOutlet weak var accountKeyTextField: UITextField!
    @IBOutlet weak var channelKeyTextField: UITextField!
    
    let cordialAPI = CordialAPI()
    
    let segueToCatalogIdentifier = "segueToCatalog"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.setBottomBorder(color: UIColor.gray)
        baseURLTextField.setBottomBorder(color: UIColor.gray)
        accountKeyTextField.setBottomBorder(color: UIColor.gray)
        channelKeyTextField.setBottomBorder(color: UIColor.gray)
        
        baseURLTextField.text = cordialAPI.getBaseURL()
        accountKeyTextField.text = cordialAPI.getAccountKey()
        channelKeyTextField.text = cordialAPI.getChannelKey()
        
        self.setupCordialSDKLogicErrorHandler ()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let primaryKey = cordialAPI.getContactPrimaryKey() {
            emailTextField.text = primaryKey
        }
    }
    
    func setupCordialSDKLogicErrorHandler () {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: .sendCustomEventsLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .sendCustomEventsLogicError, object: nil)
        
        notificationCenter.removeObserver(self, name: .upsertContactCartLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .upsertContactCartLogicError, object: nil)
        
        notificationCenter.removeObserver(self, name: .sendContactOrdersLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .sendContactOrdersLogicError, object: nil)

        notificationCenter.removeObserver(self, name: .upsertContactsLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .upsertContactsLogicError, object: nil)
        
    }
    
    @objc func cordialNotificationErrorHandler(notification: NSNotification) {
        if let error = notification.object {
            print(error)
        }
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        self.saveTestInitData()
        
        if let email = emailTextField.text, !email.isEmpty {
            cordialAPI.setContact(primaryKey: email)
            
            self.performSegue(withIdentifier: self.segueToCatalogIdentifier, sender: self)
            
        } else {
            emailTextField.setBottomBorder(color: UIColor.red)
        }
    }
    
    func saveTestInitData() {
        if let baseURL = baseURLTextField.text, let accountKey = accountKeyTextField.text, let channelKey = channelKeyTextField.text {
            cordialAPI.setBaseURL(baseURL: baseURL)
            cordialAPI.setAccountKey(accountKey: accountKey)
            cordialAPI.setChannelKey(channelKey: channelKey)
        }
    }
}

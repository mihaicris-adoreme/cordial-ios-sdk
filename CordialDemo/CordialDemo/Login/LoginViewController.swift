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
    
    let cordialAPI = CordialAPI()
    
    let segueToCatalogIdentifier = "segueToCatalog"
    let segueToSettingsIdentifier = "segueToSettings"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.setBottomBorder(color: UIColor.black)
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        self.deleteAllCartItems()
        
        if let email = emailTextField.text, !email.isEmpty {
            cordialAPI.setContact(primaryKey: email)
            
            cordialAPI.registerForPushNotifications()
            
            App.userLogIn()
            
            self.performSegue(withIdentifier: self.segueToCatalogIdentifier, sender: self)
            
        } else {
            emailTextField.setBottomBorder(color: UIColor.red)
        }
    }
    
    @IBAction func guestAction(_ sender: UIButton) {
        self.deleteAllCartItems()
        
        self.performSegue(withIdentifier: self.segueToCatalogIdentifier, sender: self)
    }
    
    func deleteAllCartItems() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let entityName = AppDataManager.shared.cartEntityName
            AppDataManager.shared.deleteAllCoreDataByEntity(appDelegate: appDelegate, entityName: entityName)
        }
    }
    
    @IBAction func settingsButtonAction(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: self.segueToSettingsIdentifier, sender: self)
    }
    
}

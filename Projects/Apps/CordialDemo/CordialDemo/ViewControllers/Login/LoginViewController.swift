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

    @IBOutlet weak var primaryKeyTextFeild: UITextField!
    
    let cordialAPI = CordialAPI()
    
    let segueToCatalogIdentifier = "segueToCatalog"
    let segueToSettingsIdentifier = "segueToSettings"
    var settingsType = App.getSettingsType()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.primaryKeyTextFeild.setBottomBorder(color: UIColor.black)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.settingsType != App.getSettingsType() {
            self.primaryKeyTextFeild.text = String()
            
        } else if let primaryKey = self.primaryKeyTextFeild.text,
                  primaryKey.isEmpty {
            
            self.primaryKeyTextFeild.text = self.cordialAPI.getContactPrimaryKey()
        }
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        self.deleteAppCoreData()
        
        if var primaryKey = self.primaryKeyTextFeild.text {
            primaryKey = primaryKey.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !primaryKey.isEmpty {
                self.cordialAPI.setContact(primaryKey: primaryKey)
                
                let isEducational = App.getNotificationCategoriesIsEducational()
                self.cordialAPI.registerForPushNotifications(options: [.alert, .sound], isEducational: isEducational)
                
                App.userLogIn()
                
                self.performSegue(withIdentifier: self.segueToCatalogIdentifier, sender: self)
            } else {
                self.primaryKeyTextFeild.setBottomBorder(color: UIColor.red)
            }
        } else {
            self.primaryKeyTextFeild.setBottomBorder(color: UIColor.red)
        }
    }
    
    @IBAction func guestAction(_ sender: UIButton) {
        self.deleteAppCoreData()
        
        self.cordialAPI.registerForPushNotifications(options: [.alert, .sound, .provisional])
        
        self.cordialAPI.setContact(primaryKey: nil)
        
        self.performSegue(withIdentifier: self.segueToCatalogIdentifier, sender: self)
    }
    
    func deleteAppCoreData() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            AppDataManager.shared.deleteAllCoreDataByEntity(appDelegate: appDelegate, entityName: AppDataManager.shared.cart.entityName)
            AppDataManager.shared.deleteAllCoreDataByEntity(appDelegate: appDelegate, entityName: AppDataManager.shared.attributes.entityName)
        }
    }
    
    @IBAction func settingsButtonAction(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: self.segueToSettingsIdentifier, sender: self)
    }
    
}

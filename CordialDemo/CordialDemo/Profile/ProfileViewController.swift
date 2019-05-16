//
//  ProfileViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 5/16/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class ProfileViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    let cordialAPI = CordialAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.setBottomBorder(color: UIColor.gray)
        
        self.title = "Profile"
        
        if let primaryKey = cordialAPI.getContactPrimaryKey() {
            emailTextField.text = primaryKey
        }
    }

    @IBAction func updateProfileButtonAction(_ sender: UIButton) {
        if let email = emailTextField.text, !email.isEmpty {
            if let primaryKey = cordialAPI.getContactPrimaryKey() {
                if primaryKey != email {
                    cordialAPI.setContact(primaryKey: email)
                }
            }
            
            let upsertContactRequest = UpsertContactRequest(attributes: nil)
            cordialAPI.upsertContact(upsertContactRequest: upsertContactRequest)
            
            popupSimpleNoteAlert(title: "PROFILE", message: "UPDATED", controller: self)
            
        } else {
            emailTextField.setBottomBorder(color: UIColor.red)
        }
    }
    
}

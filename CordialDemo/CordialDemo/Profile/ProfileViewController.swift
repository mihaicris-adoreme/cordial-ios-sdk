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

    @IBOutlet weak var primaryKeyTextField: UITextField!
    
    let cordialAPI = CordialAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.primaryKeyTextField.setBottomBorder(color: UIColor.black)
        
        self.title = "Profile"
        
        if let primaryKey = self.cordialAPI.getContactPrimaryKey() {
            self.primaryKeyTextField.text = primaryKey
        }
    }

    @IBAction func updateProfileButtonAction(_ sender: UIButton) {
        if let newPrimaryKey = self.primaryKeyTextField.text, !newPrimaryKey.isEmpty {
            if let primaryKey = self.cordialAPI.getContactPrimaryKey() {
                if primaryKey != newPrimaryKey {
                    self.cordialAPI.setContact(primaryKey: newPrimaryKey)
                }
            }
            
            let upsertContactRequest = UpsertContactRequest(attributes: nil)
            self.cordialAPI.upsertContact(upsertContactRequest: upsertContactRequest)
            
            popupSimpleNoteAlert(title: "PROFILE", message: "UPDATED", controller: self)
            
        } else {
            self.primaryKeyTextField.setBottomBorder(color: UIColor.red)
        }
    }
    
}

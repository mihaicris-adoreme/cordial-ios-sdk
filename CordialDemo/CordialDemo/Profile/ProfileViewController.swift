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
            
            // Update primary key if it has changed.
            if let primaryKey = self.cordialAPI.getContactPrimaryKey() {
                if primaryKey != newPrimaryKey {
                    self.cordialAPI.setContact(primaryKey: newPrimaryKey)
                }
            }
            
            // Test call upsertContact below just for case if some attributes are exist on the profile page.
            // Demo app did not have any attributes on the test profile page.
            self.cordialAPI.upsertContact(attributes: nil)
            
            popupSimpleNoteAlert(title: "PROFILE", message: "UPDATED", controller: self)
            
        } else {
            self.primaryKeyTextField.setBottomBorder(color: UIColor.red)
        }
    }
    
}

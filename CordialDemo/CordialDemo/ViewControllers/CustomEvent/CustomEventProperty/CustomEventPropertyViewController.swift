//
//  CustomEventPropertyViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 22.04.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit

class CustomEventPropertyViewController: UIViewController {
    
    @IBOutlet weak var propertyKeyTextField: UITextField!
    @IBOutlet weak var propertyValueTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.propertyKeyTextField.setBottomBorder(color: UIColor.lightGray)
        self.propertyValueTextField.setBottomBorder(color: UIColor.lightGray)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.propertyKeyTextField.resignFirstResponder()
        self.propertyValueTextField.resignFirstResponder()
    }
    
    @IBAction func addCustomEventPropertyAction(_ sender: UIBarButtonItem) {
        if let key = self.propertyKeyTextField.text, let value = self.propertyValueTextField.text {
            if let viewControllers = self.navigationController?.viewControllers, viewControllers.count > 2, let customEventViewController = viewControllers[viewControllers.count - 2] as? CustomEventViewController {
                
                let customEventProperty = CustomEventProperty(key: key, value: value)
                customEventViewController.properties.append(customEventProperty)
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

}

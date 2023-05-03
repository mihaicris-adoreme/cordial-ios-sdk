//
//  ImportCustomEventViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 23.04.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit

class ImportCustomEventViewController: UIViewController {

    @IBOutlet weak var jsonTextView: UITextView!
    
    var customEventJSON = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.jsonTextView.text = self.customEventJSON
    }

    @IBAction func importCustomEventAction(_ sender: UIBarButtonItem) {
        if let json = self.jsonTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) {

            var isJSONValidated = false
            
            if json.isEmpty {
                App.popupSimpleNoteAlert(title:  nil, message: "JSON cannot be empty", controller: self)
            } else {
                isJSONValidated = true
            }
            
            if isJSONValidated, let viewControllers = self.navigationController?.viewControllers, viewControllers.count > 2, let customEventViewController = viewControllers[viewControllers.count - 2] as? CustomEventViewController {
                
                do {
                    if let customEventJSONData = json.data(using: .utf8), let customEventJSONObject = try JSONSerialization.jsonObject(with: customEventJSONData, options : []) as? Dictionary<String, AnyObject> {
                        
                        customEventViewController.properties = [CustomEventProperty]()
                        if let properties = customEventJSONObject["properties"] as? Dictionary<String, String> {
                            properties.forEach { key, value in
                                let customEventProperty = CustomEventProperty(key: key, value: value)
                                customEventViewController.properties.append(customEventProperty)
                            }
                        }
                        
                        customEventViewController.eventNameTextField.text = String()
                        if let eventName = customEventJSONObject["event"] as? String {
                            customEventViewController.eventNameTextField.text = eventName
                        }
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                } catch let error {
                    App.popupSimpleNoteAlert(title: "ERROR", message: error.localizedDescription, controller: self)
                }
            }
        }
    }
    
}

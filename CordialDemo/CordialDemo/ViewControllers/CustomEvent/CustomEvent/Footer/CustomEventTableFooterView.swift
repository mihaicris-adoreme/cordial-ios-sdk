//
//  CustomEventTableFooterView.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 22.04.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class CustomEventTableFooterView: UITableViewHeaderFooterView {

    var сustomEventViewController: CustomEventViewController!
    
    @IBAction func sendCustomEventAction(_ sender: UIButton) {
        if let eventName = self.сustomEventViewController.eventNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            
            var isEventNameValidated = false
            
            if eventName.isEmpty {
                self.сustomEventViewController.eventNameInfoLabel.text = "* Event name cannot be empty."
                self.сustomEventViewController.eventNameTextField.setBottomBorder(color: UIColor.red)
            } else {
                self.сustomEventViewController.eventNameInfoLabel.text = String()
                self.сustomEventViewController.eventNameTextField.setBottomBorder(color: UIColor.lightGray)
                
                isEventNameValidated = true
            }
            
            if isEventNameValidated {
                let properties = self.сustomEventViewController.properties
                CordialAPI().sendCustomEvent(eventName: eventName, properties: self.getDictionaryProperties(properties: properties))
                
                popupSimpleNoteAlert(title: "SUCCESS", message: "Custom event has been sent", controller: сustomEventViewController)
            }
        }
    }
    
    private func getDictionaryProperties(properties: [CustomEventProperty]) -> Dictionary<String, String>? {
        var dictionaryProperties = Dictionary<String, String>()
        
        properties.forEach { property in
            dictionaryProperties[property.key] = property.value
        }
        
        if dictionaryProperties.count > 0 {
            return dictionaryProperties
        }
        
        return nil
    }
}

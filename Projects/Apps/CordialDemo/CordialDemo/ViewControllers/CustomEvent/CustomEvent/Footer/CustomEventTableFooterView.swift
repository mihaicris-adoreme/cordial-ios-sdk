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

    @IBOutlet weak var flushEventsSwitch: UISwitch!
    
    var сustomEventViewController: CustomEventViewController!
    
    let cordialAPI = CordialAPI()
    
    @IBAction func sendCustomEventAction() {
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
                self.cordialAPI.sendCustomEvent(eventName: eventName, properties: self.сustomEventViewController.getDictionaryProperties(properties: properties))
                
                if self.flushEventsSwitch.isOn {
                    self.cordialAPI.flushEvents()
                }
                
                App.popupSimpleNoteAlert(title: "SUCCESS", message: "Custom event has been sent", controller: сustomEventViewController)
            }
        }
    }
}

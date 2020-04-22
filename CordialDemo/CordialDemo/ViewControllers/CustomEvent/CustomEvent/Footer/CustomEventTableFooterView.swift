//
//  CustomEventTableFooterView.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 22.04.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit

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
                // TODO
            }
        }
    }
    
}

//
//  CustomEventViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 22.04.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class CustomEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventNameInfoLabel: UILabel!
    
    let customEventCell = "customEventTableCell"
    let customEventFooterIdentifier = "customEventTableFooter"
    let segueToImportCustomEventIdentifier = "segueToImportCustomEvent"
    let segueToCustomEventPropertyIdentifier = "segueToCustomEventProperty"
    
    var properties = [CustomEventProperty]()
    
    var customEventTableFooterView: CustomEventTableFooterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(UINib(nibName: "CustomEventTableFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: self.customEventFooterIdentifier)
        self.customEventTableFooterView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: self.customEventFooterIdentifier) as? CustomEventTableFooterView
        
        self.customEventTableFooterView.сustomEventViewController = self
        
        self.eventNameTextField.setBottomBorder(color: UIColor.lightGray)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.eventNameTextField.resignFirstResponder()
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.reloadData()
    }
    
    @IBAction func customEventPropertyAction(_ sender: UIButton) {
        self.eventNameTextField.resignFirstResponder()
        self.performSegue(withIdentifier: self.segueToCustomEventPropertyIdentifier, sender: self)
    }
    
    @IBAction func exportCustomEventAction(_ sender: UIBarButtonItem) {
        if let eventName = self.eventNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            
            var isEventNameValidated = false
            
            if eventName.isEmpty {
                self.eventNameInfoLabel.text = "* Event name cannot be empty."
                self.eventNameTextField.setBottomBorder(color: UIColor.red)
            } else {
                self.eventNameInfoLabel.text = String()
                self.eventNameTextField.setBottomBorder(color: UIColor.lightGray)
                
                isEventNameValidated = true
            }
            
            if isEventNameValidated {
                self.eventNameTextField.resignFirstResponder()
                self.performSegue(withIdentifier: self.segueToImportCustomEventIdentifier, sender: self)
            }
        }
    }
    
    func getDictionaryProperties(properties: [CustomEventProperty]) -> Dictionary<String, String>? {
        var dictionaryProperties = Dictionary<String, String>()
        
        properties.forEach { property in
            dictionaryProperties[property.key] = property.value
        }
        
        if dictionaryProperties.count > 0 {
            return dictionaryProperties
        }
        
        return nil
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case self.segueToImportCustomEventIdentifier:
            if let eventName = self.eventNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let importCustomEventViewController = segue.destination as? ImportCustomEventViewController {
                
                let properties = self.getDictionaryProperties(properties: self.properties)
                
                let customEventJSON = CordialAPI().getCustomEventJSON(eventName: eventName, properties: properties)
                
                do {
                    if let customEventJSONData = customEventJSON.data(using: .utf8), let customEventJSONObject = try JSONSerialization.jsonObject(with: customEventJSONData, options : []) as? Dictionary<String, AnyObject> {
                        
                        let prettyCustomEventJSONData = try JSONSerialization.data(withJSONObject: customEventJSONObject, options: .prettyPrinted)
        
                        if let prettyCustomEventJSON = String(data: prettyCustomEventJSONData, encoding: .utf8) {
                            importCustomEventViewController.customEventJSON = prettyCustomEventJSON
                        }
                    }
                } catch let error {
                    popupSimpleNoteAlert(title: "ERROR", message: error.localizedDescription, controller: self)
                }
            }
        default:
            break
        }
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.customEventTableFooterView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.customEventTableFooterView.frame.size.height
    }
    
    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.properties.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.customEventCell, for: indexPath) as! CustomEventTableViewCell

        let property = self.properties[indexPath.row]
        
        cell.keyLabel.text = property.key
        cell.valueLabel.text = property.value
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            self.properties.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            self.tableView.reloadData()
        }
    }
    
}

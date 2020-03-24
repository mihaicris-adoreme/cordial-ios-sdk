//
//  AttributesViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 13.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class AttributesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var keyInfoLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var valueInfoLabel: UILabel!
    @IBOutlet weak var booleanSwitch: UISwitch!
    @IBOutlet weak var attributeDatePicker: UIDatePicker!
    
    let segueToGeoIdentifier = "segueToGeo"
    
    var pickerData: [String] = [String]()
    
    var attributeType = AttributeType.string
    var attributeDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Attribute"
        
        self.attributeType = AttributeType.string
        
        self.keyTextField.setBottomBorder(color: UIColor.lightGray)
        self.valueTextField.setBottomBorder(color: UIColor.lightGray)
        
        self.pickerData = ["String", "Boolean", "Numeric", "Array", "Date", "Geo"]
    }
    
    @IBAction func addAttributeAction(_ sender: UIBarButtonItem) {
        if let key = self.keyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), var value = self.valueTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            var isKeyValidated = false
            var isValueValidated = false
            
            if key.isEmpty {
                self.keyInfoLabel.text = "* Key cannot be empty."
                self.keyTextField.setBottomBorder(color: UIColor.red)
            } else {
                self.keyInfoLabel.text = String()
                self.keyTextField.setBottomBorder(color: UIColor.lightGray)
                
                isKeyValidated = true
            }
            
            switch self.attributeType {
            case AttributeType.string:
                isValueValidated  = true
            case AttributeType.boolean:
                isValueValidated = true
                
                if self.booleanSwitch.isOn {
                    value = "true"
                } else {
                    value = "false"
                }
            case AttributeType.numeric:
                if value.isEmpty {
                    self.valueInfoLabel.text = "* Numeric value cannot be empty."
                    self.valueTextField.setBottomBorder(color: UIColor.red)
                    
                    isValueValidated = false
                } else {
                    self.valueInfoLabel.text = String()
                    self.valueTextField.setBottomBorder(color: UIColor.lightGray)
                    
                    value = value.replacingOccurrences(of: ",", with: ".")
                    isValueValidated = true
                }
            case AttributeType.array:
                isValueValidated = true
            case AttributeType.date:
                let date = AppDateFormatter().getDateFromTimestamp(timestamp: value)!
                value = CordialDateFormatter().getTimestampFromDate(date: date)
                isValueValidated = true
            }
            
            if isKeyValidated && isValueValidated  {
                let attribute = Attribute(key: key, type: self.attributeType, value: value)
                AppDataManager.shared.attributes.putAttributeToCoreData(appDelegate: appDelegate, attribute: attribute)
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func booleanSwitchAction(_ sender: UISwitch) {
        self.valueInfoLabel.textAlignment = .right
        
        if self.booleanSwitch.isOn {
            self.booleanSwitch.setOn(true, animated: true)
            self.valueInfoLabel.text = "TRUE"
        } else {
            self.booleanSwitch.setOn(false, animated: true)
            self.valueInfoLabel.text = "FALSE"
        }
    }
    
    @IBAction func attributeDatePickerAction(_ sender: UIDatePicker) {
        self.attributeDate = sender.date
        self.valueTextField.text = AppDateFormatter().getTimestampFromDate(date: sender.date)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case self.segueToGeoIdentifier:
            if let geoViewController = segue.destination as? GeoViewController {
                geoViewController.attributesViewController = self
            }
        default:
            break
        }
    }
    
    // MARK: UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    // MARK: UIPickerViewDataSource
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.keyTextField.setBottomBorder(color: UIColor.lightGray)
        self.keyTextField.resignFirstResponder()
        
        self.valueTextField.text = String()
        self.valueTextField.setBottomBorder(color: UIColor.lightGray)
        self.valueTextField.resignFirstResponder()
        
        switch self.pickerData[row].lowercased() {
        case AttributeType.string.rawValue:
            self.attributeType = AttributeType.string
            self.valueTextField.keyboardType = .asciiCapable
            self.valueInfoLabel.textAlignment = .left
            self.valueInfoLabel.text = String()
            self.valueTextField.isHidden = false
            self.valueTextField.isUserInteractionEnabled = true
            self.booleanSwitch.isHidden = true
            self.attributeDatePicker.isHidden = true
        case AttributeType.boolean.rawValue:
            self.attributeType = AttributeType.boolean
            self.valueTextField.keyboardType = .asciiCapable
            self.valueInfoLabel.textAlignment = .right
            if self.booleanSwitch.isOn {
                self.valueInfoLabel.text = "TRUE"
            } else {
                self.valueInfoLabel.text = "FALSE"
            }
            self.valueTextField.isHidden = true
            self.valueTextField.isUserInteractionEnabled = true
            self.booleanSwitch.isHidden = false
            self.attributeDatePicker.isHidden = true
        case AttributeType.numeric.rawValue:
            self.attributeType = AttributeType.numeric
            self.valueTextField.keyboardType = .decimalPad
            self.valueInfoLabel.textAlignment = .left
            self.valueInfoLabel.text = String()
            self.valueTextField.isHidden = false
            self.valueTextField.isUserInteractionEnabled = true
            self.booleanSwitch.isHidden = true
            self.attributeDatePicker.isHidden = true
        case AttributeType.array.rawValue:
            self.attributeType = AttributeType.array
            self.valueTextField.keyboardType = .asciiCapable
            self.valueInfoLabel.textAlignment = .left
            self.valueInfoLabel.text = "* Сomma separated values."
            self.valueTextField.isHidden = false
            self.valueTextField.isUserInteractionEnabled = true
            self.booleanSwitch.isHidden = true
            self.attributeDatePicker.isHidden = true
        case AttributeType.date.rawValue:
            self.attributeType = AttributeType.date
            self.valueTextField.keyboardType = .asciiCapable
            self.valueInfoLabel.textAlignment = .left
            self.valueInfoLabel.text = String()
            self.valueTextField.isHidden = false
            self.valueTextField.isUserInteractionEnabled = false
            self.booleanSwitch.isHidden = true
            self.attributeDatePicker.isHidden = false
            if let date = self.attributeDate {
                self.valueTextField.text = AppDateFormatter().getTimestampFromDate(date: date)
            } else {
                self.valueTextField.text = AppDateFormatter().getTimestampFromDate(date: Date())
            }
//        case AttributeType.geo.rawValue:
            case "geo":
            self.performSegue(withIdentifier: self.segueToGeoIdentifier, sender: self)
            break
        default:
            break
        }
        
    }
}

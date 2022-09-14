//
//  AttributeViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 13.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class AttributeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var keyInfoLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var valueInfoLabel: UILabel!
    @IBOutlet weak var booleanSwitch: UISwitch!
    @IBOutlet weak var nullSwitch: UISwitch!
    @IBOutlet weak var nullLabel: UILabel!
    @IBOutlet weak var attributeDatePicker: UIDatePicker!
    
    let segueToGeoIdentifier = "segueToGeo"
    
    var pickerData = [String]()
    
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
        if let key = self.keyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            var value = self.valueTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            var isKeyValidated = false
            var isValueValidated = false
            
            if key.isEmpty {
                self.markKeyInfo(text: "* Key cannot be empty.")
            } else {
                isKeyValidated = true
                
                self.unmarkKeyInfo()
            }
            
            switch self.attributeType {
            case AttributeType.string:
                isValueValidated = true
                
                if self.nullSwitch.isOn {
                    value = nil
                }
            case AttributeType.boolean:
                isValueValidated = true
                
                if self.booleanSwitch.isOn {
                    value = "true"
                } else {
                    value = "false"
                }
            case AttributeType.numeric:
                isValueValidated = true
                
                if self.nullSwitch.isOn {
                    value = nil
                    self.unmarkValueInfo()
                } else if value != nil, value!.isEmpty {
                    self.markValueInfo(text: "* Numeric value cannot be empty.")
                    
                    isValueValidated = false
                } else {
                    self.unmarkValueInfo()
                    
                    value = value!.replacingOccurrences(of: ",", with: ".")
                }
            case AttributeType.array:
                isValueValidated = true
            case AttributeType.date:
                isValueValidated = true
                
                if self.nullSwitch.isOn {
                    value = nil
                } else if let date = AppDateFormatter().getDateFromTimestamp(timestamp: value!) {
                    value = CordialDateFormatter().getTimestampFromDate(date: date)
                } else {
                    self.markValueInfo(text: "* Date value is not a date.")
                    
                    isValueValidated = false
                }
            case AttributeType.geo:
                break
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
    
    @IBAction func nullSwitchAction(_ sender: UISwitch) {
        if self.nullSwitch.isOn {
            self.nullSwitchOn(animated: true)
        } else {
            self.nullSwitchOff(animated: true)
        }
    }
    
    @IBAction func attributeDatePickerAction(_ sender: UIDatePicker) {
        self.attributeDate = sender.date
        self.valueTextField.text = AppDateFormatter().getTimestampFromDate(date: sender.date)
    }
    
    // MARK: NullSwitch
    
    private func nullSwitchOn(animated: Bool) {
        self.nullSwitch.setOn(true, animated: animated)
        self.valueTextField.text = String()
        self.valueTextField.isUserInteractionEnabled = false
    }
    
    private func nullSwitchOff(animated: Bool) {
        self.nullSwitch.setOn(false, animated: animated)
        self.valueTextField.isUserInteractionEnabled = true
    }
    
    // MARK: KeyInfo
    
    private func markKeyInfo (text: String) {
        self.keyInfoLabel.text = text
        self.keyInfoLabel.textColor = UIColor.red
        self.keyTextField.setBottomBorder(color: UIColor.red)
    }
    
    private func unmarkKeyInfo () {
        self.keyInfoLabel.text = String()
        self.keyInfoLabel.textColor = UIColor.black
        self.keyTextField.setBottomBorder(color: UIColor.lightGray)
    }
    
    // MARK: ValueInfo

    private func markValueInfo (text: String) {
        self.valueInfoLabel.text = text
        self.valueInfoLabel.textColor = UIColor.red
        self.valueTextField.setBottomBorder(color: UIColor.red)
    }
        
    private func unmarkValueInfo () {
        self.valueInfoLabel.text = String()
        self.valueInfoLabel.textColor = UIColor.black
        self.valueTextField.setBottomBorder(color: UIColor.lightGray)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case self.segueToGeoIdentifier:
            if let geoAttributeViewController = segue.destination as? GeoAttributeViewController {
                geoAttributeViewController.attributeViewController = self
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
        return self.pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.nullSwitchOff(animated: false)
        
        self.keyTextField.setBottomBorder(color: UIColor.lightGray)
        self.keyTextField.resignFirstResponder()
        
        self.unmarkKeyInfo()
        
        self.valueTextField.text = String()
        self.valueTextField.setBottomBorder(color: UIColor.lightGray)
        self.valueTextField.resignFirstResponder()
        
        self.unmarkValueInfo()
        
        switch self.pickerData[row].lowercased() {
        case AttributeType.string.rawValue:
            self.attributeType = AttributeType.string
            self.valueTextField.keyboardType = .asciiCapable
            self.valueInfoLabel.textAlignment = .left
            self.valueInfoLabel.text = String()
            self.valueTextField.isHidden = false
            self.valueTextField.isUserInteractionEnabled = true
            self.booleanSwitch.isHidden = true
            self.nullSwitch.isHidden = false
            self.nullLabel.isHidden = false
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
            self.nullSwitch.isHidden = true
            self.nullLabel.isHidden = true
            self.attributeDatePicker.isHidden = true
        case AttributeType.numeric.rawValue:
            self.attributeType = AttributeType.numeric
            self.valueTextField.keyboardType = .decimalPad
            self.valueInfoLabel.textAlignment = .left
            self.valueInfoLabel.text = String()
            self.valueTextField.isHidden = false
            self.valueTextField.isUserInteractionEnabled = true
            self.booleanSwitch.isHidden = true
            self.nullSwitch.isHidden = false
            self.nullLabel.isHidden = false
            self.attributeDatePicker.isHidden = true
        case AttributeType.array.rawValue:
            self.attributeType = AttributeType.array
            self.valueTextField.keyboardType = .asciiCapable
            self.valueInfoLabel.textAlignment = .left
            self.valueInfoLabel.text = "* Сomma separated values."
            self.valueTextField.isHidden = false
            self.valueTextField.isUserInteractionEnabled = true
            self.booleanSwitch.isHidden = true
            self.nullSwitch.isHidden = true
            self.nullLabel.isHidden = true
            self.attributeDatePicker.isHidden = true
        case AttributeType.date.rawValue:
            self.attributeType = AttributeType.date
            self.valueTextField.keyboardType = .asciiCapable
            self.valueInfoLabel.textAlignment = .left
            self.valueInfoLabel.text = String()
            self.valueTextField.isHidden = false
            self.valueTextField.isUserInteractionEnabled = false
            self.booleanSwitch.isHidden = true
            self.nullSwitch.isHidden = false
            self.nullLabel.isHidden = false
            self.attributeDatePicker.isHidden = false
            if let date = self.attributeDate {
                self.valueTextField.text = AppDateFormatter().getTimestampFromDate(date: date)
            } else {
                self.valueTextField.text = AppDateFormatter().getTimestampFromDate(date: Date())
            }
        case AttributeType.geo.rawValue:
            self.performSegue(withIdentifier: self.segueToGeoIdentifier, sender: self)
        default:
            break
        }
        
    }
}

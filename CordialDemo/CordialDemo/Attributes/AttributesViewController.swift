//
//  AttributesViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 13.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit

class AttributesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var keyInfoLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var valueInfoLabel: UILabel!
    
    var pickerData: [String] = [String]()
    
    var type = AttributeType.string
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.title = "Attribute"
        
        self.keyTextField.setBottomBorder(color: UIColor.lightGray)
        self.valueTextField.setBottomBorder(color: UIColor.lightGray)
        
        self.pickerData = ["String", "Boolean", "Numeric", "Array"]
    }
    
    @IBAction func addButtonAction(_ sender: UIBarButtonItem) {
        if let key = self.keyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let value = self.valueTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
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
            
            switch self.type {
            case AttributeType.string:
                isValueValidated  = true
            case AttributeType.boolean:
                if value.lowercased() == "true" || value.lowercased() == "false" {
                    self.valueTextField.setBottomBorder(color: UIColor.lightGray)
                    self.valueInfoLabel.text = String()
                    
                    isValueValidated = true
                } else {
                    self.valueTextField.setBottomBorder(color: UIColor.red)
                }
            case AttributeType.numeric:
                isValueValidated = true
            case AttributeType.array:
                isValueValidated = false
            }
            
            if isKeyValidated && isValueValidated  {
                let attribute = Attribute(key: key, type: self.type, value: value)
                AppDataManager.shared.attributes.putAttributeToCoreData(appDelegate: appDelegate, attribute: attribute)
                
                self.navigationController?.popViewController(animated: true)
            }
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
            self.type = AttributeType.string
            self.valueTextField.keyboardType = .asciiCapable
            self.valueInfoLabel.text = String()
        case AttributeType.boolean.rawValue:
            self.type = AttributeType.boolean
            self.valueTextField.keyboardType = .asciiCapable
            self.valueInfoLabel.text = "* Please write word TRUE or FALSE."
        case AttributeType.numeric.rawValue:
            self.type = AttributeType.numeric
            self.valueTextField.keyboardType = .decimalPad
            self.valueInfoLabel.text = String()
        case AttributeType.array.rawValue:
            self.type = AttributeType.array
            self.valueTextField.keyboardType = .asciiCapable
            self.valueInfoLabel.text = "* Please use comma as separator."
        default:
            break
        }
        
    }
}

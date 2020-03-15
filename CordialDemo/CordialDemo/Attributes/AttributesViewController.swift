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
    @IBOutlet weak var valueTextField: UITextField!
    
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
        if let key = self.keyTextField.text, let value = self.valueTextField.text, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            let attribute = Attribute(key: key, type: self.type, value: value)
            AppDataManager.shared.attributes.putAttributeToCoreData(appDelegate: appDelegate, attribute: attribute)
        }
        
        self.navigationController?.popViewController(animated: true)
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
        
        switch self.pickerData[row].lowercased() {
        case AttributeType.string.rawValue:
            self.type = AttributeType.string
        case AttributeType.boolean.rawValue:
            self.type = AttributeType.boolean
        case AttributeType.numeric.rawValue:
            self.type = AttributeType.numeric
        case AttributeType.array.rawValue:
            self.type = AttributeType.array
        default:
            break
        }
        
    }
}

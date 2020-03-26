//
//  GeoAttributeViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 23.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit

class GeoAttributeViewController: UIViewController, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var keyInfoLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var streetAddressTextField: UITextField!
    @IBOutlet weak var streetAddress2TextField: UITextField!
    @IBOutlet weak var timeZoneTextField: UITextField!
    
    var attributeViewController: AttributeViewController?
    
    let countryPicker = UIPickerView()
    var countryPickerData = [String]()
    
    let timeZonePicker = UIPickerView()
    var timeZonePickerData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Geo"
        
        self.navigationController?.delegate = self
        self.countryPicker.delegate = self
        self.timeZonePicker.delegate = self
        
        self.keyTextField.setBottomBorder(color: UIColor.lightGray)
        self.cityTextField.setBottomBorder(color: UIColor.lightGray)
        self.countryTextField.setBottomBorder(color: UIColor.lightGray)
        self.postalCodeTextField.setBottomBorder(color: UIColor.lightGray)
        self.stateTextField.setBottomBorder(color: UIColor.lightGray)
        self.streetAddressTextField.setBottomBorder(color: UIColor.lightGray)
        self.streetAddress2TextField.setBottomBorder(color: UIColor.lightGray)
        self.timeZoneTextField.setBottomBorder(color: UIColor.lightGray)
        
        self.countryPickerData = ["", "United States of America", "United Kingdom (Great Britain)", "France", "Italy"]
        self.timeZonePickerData = ["", "America/Los_Angeles", "Europe/London", "Europe/Paris", "Europe/Rome"]
        
        self.addPickerToCountryTextField()
    }
    
    @IBAction func addGeoAttributeAction(_ sender: UIBarButtonItem) {
        if let key = self.keyTextField.text, key.isEmpty {
            self.keyInfoLabel.text = "* Key cannot be empty."
            self.keyTextField.setBottomBorder(color: UIColor.red)
        } else {
            self.keyInfoLabel.text = String()
            self.keyTextField.setBottomBorder(color: UIColor.lightGray)
            
            self.addNewGeoAttributeAndNavigateToProfileViewController()
        }
    }
    
    private func addNewGeoAttributeAndNavigateToProfileViewController() {
        if let viewControllers = self.navigationController?.viewControllers, viewControllers.count > 3, let appDelegate = UIApplication.shared.delegate as? AppDelegate, let key = self.keyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let city = self.cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let country = self.countryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let postalCode = self.postalCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let state = self.stateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let streetAddress = self.streetAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let streetAddress2 = self.streetAddress2TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let timeZone = self.timeZoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            
            let geoAttribute = GeoAttribute(key: key, city: city, country: country, postalCode: postalCode, state: state, streetAddress: streetAddress, streetAddress2: streetAddress2, timeZone: timeZone)
            AppDataManager.shared.geoAttributes.putGeoAttributeToCoreData(appDelegate: appDelegate, geoAttribute: geoAttribute)
            
            let attribute = Attribute(key: key, type: AttributeType.geo, value: String())
            AppDataManager.shared.attributes.putAttributeToCoreData(appDelegate: appDelegate, attribute: attribute)
            
            self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
         }
    }
    
    private func addPickerToCountryTextField() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        self.cityTextField.inputAccessoryView = toolbar
        
        self.countryTextField.tintColor = UIColor.clear
        
        self.countryPicker.tag = 1
        self.countryTextField.inputView = self.countryPicker
        
        self.timeZoneTextField.isUserInteractionEnabled = false
    }
    
    // MARK: UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let attributeViewController = self.attributeViewController {
            attributeViewController.loadView()
            attributeViewController.viewDidLoad()
        }
    }
    
    // MARK: UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    // MARK: UIPickerViewDataSource
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return self.countryPickerData.count
        }
        
        return self.timeZonePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return self.countryPickerData[row]
        }
        
        return self.timeZonePickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            self.countryTextField.text = self.countryPickerData[row]
        }
        
        self.timeZoneTextField.text = self.timeZonePickerData[row]
    }
    
}

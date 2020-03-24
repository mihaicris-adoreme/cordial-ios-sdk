//
//  GeoAttributeViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 23.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit

class GeoAttributeViewController: UIViewController, UINavigationControllerDelegate {
    
    var attributeViewController: AttributeViewController?
    
    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var streetAdressTextField: UITextField!
    @IBOutlet weak var streetAdress2TextField: UITextField!
    @IBOutlet weak var timeZoneTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Geo"
        
        self.navigationController?.delegate = self
        
        self.keyTextField.setBottomBorder(color: UIColor.lightGray)
        self.cityTextField.setBottomBorder(color: UIColor.lightGray)
        self.countryTextField.setBottomBorder(color: UIColor.lightGray)
        self.postalCodeTextField.setBottomBorder(color: UIColor.lightGray)
        self.stateTextField.setBottomBorder(color: UIColor.lightGray)
        self.streetAdressTextField.setBottomBorder(color: UIColor.lightGray)
        self.streetAdress2TextField.setBottomBorder(color: UIColor.lightGray)
        self.timeZoneTextField.setBottomBorder(color: UIColor.lightGray)
        
    }
    
    @IBAction func addGeoAttributeAction(_ sender: UIBarButtonItem) {
        if let viewControllers = self.navigationController?.viewControllers, viewControllers.count > 3, let appDelegate = UIApplication.shared.delegate as? AppDelegate, let key = self.keyTextField.text, let city = self.cityTextField.text, let country = self.countryTextField.text, let postalCode = self.postalCodeTextField.text, let state = self.stateTextField.text, let streetAdress = self.streetAdressTextField.text, let streetAdress2 = self.streetAdress2TextField.text, let timeZone = self.timeZoneTextField.text {
            
            let geoAttribute = GeoAttribute(key: key, city: city, country: country, postalCode: postalCode, state: state, streetAdress: streetAdress, streetAdress2: streetAdress2, timeZone: timeZone)
            AppDataManager.shared.geoAttributes.putGeoAttributeToCoreData(appDelegate: appDelegate, geoAttribute: geoAttribute)
            
            let attribute = Attribute(key: key, type: AttributeType.geo, value: String())
            AppDataManager.shared.attributes.putAttributeToCoreData(appDelegate: appDelegate, attribute: attribute)
            
            self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
         }
    }
    
    // MARK: UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let attributeViewController = self.attributeViewController {
            attributeViewController.loadView()
            attributeViewController.viewDidLoad()
        }
    }
}

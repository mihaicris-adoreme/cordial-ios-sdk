//
//  GeoViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 23.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit

class GeoViewController: UIViewController, UINavigationControllerDelegate {
    
    var attributesViewController: AttributesViewController?
    
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
        
        self.cityTextField.setBottomBorder(color: UIColor.lightGray)
        self.countryTextField.setBottomBorder(color: UIColor.lightGray)
        self.postalCodeTextField.setBottomBorder(color: UIColor.lightGray)
        self.stateTextField.setBottomBorder(color: UIColor.lightGray)
        self.streetAdressTextField.setBottomBorder(color: UIColor.lightGray)
        self.streetAdress2TextField.setBottomBorder(color: UIColor.lightGray)
        self.timeZoneTextField.setBottomBorder(color: UIColor.lightGray)
        
    }
    
    @IBAction func addGeoAttributeAction(_ sender: UIBarButtonItem) {
        if let viewControllers = self.navigationController?.viewControllers, viewControllers.count > 3 {
             self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
         }
    }
    
    // MARK: UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let attributesViewController = self.attributesViewController {
            attributesViewController.loadView()
            attributesViewController.viewDidLoad()
        }
    }
}

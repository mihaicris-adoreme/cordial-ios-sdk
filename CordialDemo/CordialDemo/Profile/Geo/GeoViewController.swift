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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Geo"
        
        self.navigationController?.delegate = self
    }
    
    // MARK: UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let attributesViewController = self.attributesViewController {
            attributesViewController.loadView()
            attributesViewController.viewDidLoad()
        }
    }
}

//
//  ExternalDisplayViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 13.09.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class ExternalDisplayViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .yellow
        
        CordialAPI().showSystemAlert(title: "ExternalDisplay", message: "")
    }
}

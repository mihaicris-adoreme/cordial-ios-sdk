//
//  ImportCustomEventViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 23.04.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit

class ImportCustomEventViewController: UIViewController {

    @IBOutlet weak var jsonTextView: UITextView!
    
    var customEventJSON = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.jsonTextView.text = self.customEventJSON
    }

    @IBAction func importCustomEventAction(_ sender: UIBarButtonItem) {
        
    }
    
}

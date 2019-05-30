//
//  SettingsViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 5/30/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class SettingsViewController: UIViewController {

    @IBOutlet weak var baseURLTextField: UITextField!
    @IBOutlet weak var accountKeyTextField: UITextField!
    @IBOutlet weak var channelKeyTextField: UITextField!
    
    let cordialAPI = CordialAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        baseURLTextField.setBottomBorder(color: UIColor.gray)
        accountKeyTextField.setBottomBorder(color: UIColor.gray)
        channelKeyTextField.setBottomBorder(color: UIColor.gray)
        
        baseURLTextField.text = cordialAPI.getBaseURL()
        accountKeyTextField.text = cordialAPI.getAccountKey()
        channelKeyTextField.text = cordialAPI.getChannelKey()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.saveTestInitData()
    }

    func saveTestInitData() {
        if let baseURL = baseURLTextField.text, let accountKey = accountKeyTextField.text, let channelKey = channelKeyTextField.text {
            cordialAPI.setBaseURL(baseURL: baseURL)
            cordialAPI.setAccountKey(accountKey: accountKey)
            cordialAPI.setChannelKey(channelKey: channelKey)
        }
    }
}

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
    @IBOutlet weak var qtyCachedEventQueueTextField: UITextField!
    
    let cordialAPI = CordialAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Settings"
        
        baseURLTextField.setBottomBorder(color: UIColor.black)
        accountKeyTextField.setBottomBorder(color: UIColor.black)
        channelKeyTextField.setBottomBorder(color: UIColor.black)
        qtyCachedEventQueueTextField.setBottomBorder(color: UIColor.black)
        
        baseURLTextField.text = self.cordialAPI.getBaseURL()
        accountKeyTextField.text = self.cordialAPI.getAccountKey()
        channelKeyTextField.text = self.cordialAPI.getChannelKey()
        qtyCachedEventQueueTextField.text = String(CordialApiConfiguration.shared.qtyCachedEventQueue)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.saveTestInitData()
    }

    func saveTestInitData() {
        if let baseURL = self.baseURLTextField.text, let accountKey = self.accountKeyTextField.text, let channelKey = self.channelKeyTextField.text, let qtyCachedEventQueueString = self.qtyCachedEventQueueTextField.text, let qtyCachedEventQueue = Int(qtyCachedEventQueueString) {
            self.cordialAPI.setBaseURL(baseURL: baseURL)
            self.cordialAPI.setAccountKey(accountKey: accountKey)
            self.cordialAPI.setChannelKey(channelKey: channelKey)
            CordialApiConfiguration.shared.qtyCachedEventQueue = qtyCachedEventQueue
        }
    }
}

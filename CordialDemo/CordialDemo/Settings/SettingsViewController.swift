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

        baseURLTextField.setBottomBorder(color: UIColor.gray)
        accountKeyTextField.setBottomBorder(color: UIColor.gray)
        channelKeyTextField.setBottomBorder(color: UIColor.gray)
        qtyCachedEventQueueTextField.setBottomBorder(color: UIColor.gray)
        
        baseURLTextField.text = cordialAPI.getBaseURL()
        accountKeyTextField.text = cordialAPI.getAccountKey()
        channelKeyTextField.text = cordialAPI.getChannelKey()
        qtyCachedEventQueueTextField.text = String(CordialApiConfiguration.shared.qtyCachedEventQueue)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.saveTestInitData()
    }

    func saveTestInitData() {
        if let baseURL = self.baseURLTextField.text, let accountKey = self.accountKeyTextField.text, let channelKey = self.channelKeyTextField.text, let qtyCachedEventQueueString = self.qtyCachedEventQueueTextField.text, let qtyCachedEventQueue = Int(qtyCachedEventQueueString) {
            cordialAPI.setBaseURL(baseURL: baseURL)
            cordialAPI.setAccountKey(accountKey: accountKey)
            cordialAPI.setChannelKey(channelKey: channelKey)
            CordialApiConfiguration.shared.qtyCachedEventQueue = qtyCachedEventQueue
        }
    }
}

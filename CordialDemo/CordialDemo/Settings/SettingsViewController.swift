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
        
        self.baseURLTextField.setBottomBorder(color: UIColor.black)
        self.accountKeyTextField.setBottomBorder(color: UIColor.black)
        self.channelKeyTextField.setBottomBorder(color: UIColor.black)
        self.qtyCachedEventQueueTextField.setBottomBorder(color: UIColor.black)
        
        self.baseURLTextField.text = self.cordialAPI.getBaseURL()
        self.accountKeyTextField.text = self.cordialAPI.getAccountKey()
        self.channelKeyTextField.text = self.cordialAPI.getChannelKey()
        self.qtyCachedEventQueueTextField.text = String(CordialApiConfiguration.shared.qtyCachedEventQueue)
        
        self.updateSettingsPage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.saveTestInitData()
    }
    
    @IBAction func choosePresetAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Settings", message: "Choose Preset", preferredStyle: .actionSheet)

        let qcAction = UIAlertAction(title: Settings.qc.rawValue, style: .default) { action in
            App.setSavedSettingsType(settingsType: Settings.qc.rawValue)
            
            self.updateSettingsPage()
        }
        
        let stagingAction = UIAlertAction(title: Settings.staging.rawValue, style: .default) { action in
            App.setSavedSettingsType(settingsType: Settings.staging.rawValue)
            
            self.updateSettingsPage()
        }
        
        let prodAction = UIAlertAction(title: Settings.production.rawValue, style: .default) { action in
            App.setSavedSettingsType(settingsType: Settings.production.rawValue)
            
            self.updateSettingsPage()
        }
        
        let customAction = UIAlertAction(title: Settings.custom.rawValue, style: .default) { action in
            App.setSavedSettingsType(settingsType: Settings.custom.rawValue)
            
            self.updateSettingsPage()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(qcAction)
        alertController.addAction(stagingAction)
        alertController.addAction(prodAction)
        alertController.addAction(customAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)

    }
    
    func saveTestInitData() {
        if let baseURL = self.baseURLTextField.text, let accountKey = self.accountKeyTextField.text, let channelKey = self.channelKeyTextField.text, let qtyCachedEventQueueString = self.qtyCachedEventQueueTextField.text, let qtyCachedEventQueue = Int(qtyCachedEventQueueString) {
            self.cordialAPI.setBaseURL(baseURL: baseURL)
            self.cordialAPI.setAccountKey(accountKey: accountKey)
            self.cordialAPI.setChannelKey(channelKey: channelKey)
            CordialApiConfiguration.shared.qtyCachedEventQueue = qtyCachedEventQueue
        }
    }
    
    func updateSettingsPage() {
        switch App.getSavedSettingsType() {
        case Settings.qc.rawValue:
            self.title = Settings.qc.rawValue
            
            let qcSettings = self.getQCSettings()
            
            self.baseURLTextField.text = qcSettings.baseURL
            self.accountKeyTextField.text = qcSettings.accountKey
            self.channelKeyTextField.text = qcSettings.channelKey
            self.qtyCachedEventQueueTextField.text = String(qcSettings.qtyCachedEventQueue)
            
            self.baseURLTextField.isUserInteractionEnabled = false
            self.accountKeyTextField.isUserInteractionEnabled = false
            self.channelKeyTextField.isUserInteractionEnabled = false
            self.qtyCachedEventQueueTextField.isUserInteractionEnabled = false
        case Settings.staging.rawValue:
            self.title = Settings.staging.rawValue
            
            let stagingSettings = self.getStagingSettings()
            
            self.baseURLTextField.text = stagingSettings.baseURL
            self.accountKeyTextField.text = stagingSettings.accountKey
            self.channelKeyTextField.text = stagingSettings.channelKey
            self.qtyCachedEventQueueTextField.text = String(stagingSettings.qtyCachedEventQueue)
            
            self.baseURLTextField.isUserInteractionEnabled = false
            self.accountKeyTextField.isUserInteractionEnabled = false
            self.channelKeyTextField.isUserInteractionEnabled = false
            self.qtyCachedEventQueueTextField.isUserInteractionEnabled = false
        case Settings.production.rawValue:
            self.title = Settings.production.rawValue
            
            let productionSettings = self.getProductionSettings()
            
            self.baseURLTextField.text = productionSettings.baseURL
            self.accountKeyTextField.text = productionSettings.accountKey
            self.channelKeyTextField.text = productionSettings.channelKey
            self.qtyCachedEventQueueTextField.text = String(productionSettings.qtyCachedEventQueue)
            
            self.baseURLTextField.isUserInteractionEnabled = false
            self.accountKeyTextField.isUserInteractionEnabled = false
            self.channelKeyTextField.isUserInteractionEnabled = false
            self.qtyCachedEventQueueTextField.isUserInteractionEnabled = false
        default:
            self.title = Settings.custom.rawValue
            
            self.baseURLTextField.isUserInteractionEnabled = true
            self.accountKeyTextField.isUserInteractionEnabled = true
            self.channelKeyTextField.isUserInteractionEnabled = true
            self.qtyCachedEventQueueTextField.isUserInteractionEnabled = true
        }
    }
    
    func getQCSettings() -> Credentials {
        let baseURL = "https://events-stream-svc.cordial-core.mobile-sdk-1-5.cordialdev.com/"
        let accountKey = "qc-all-channels"
        let channelKey = "push"
        let qtyCachedEventQueue = 100
        
        return Credentials(baseURL: baseURL, accountKey: accountKey, channelKey: channelKey, qtyCachedEventQueue: qtyCachedEventQueue)
    }
    
    func getStagingSettings() -> Credentials {
        let baseURL = "https://events-stream-svc.stg.cordialdev.com/"
        let accountKey = "stgtaras"
        let channelKey = "sdk"
        let qtyCachedEventQueue = 100
        
        return Credentials(baseURL: baseURL, accountKey: accountKey, channelKey: channelKey, qtyCachedEventQueue: qtyCachedEventQueue)
    }
    
    func getProductionSettings() -> Credentials {
        let baseURL = "https://events-stream-svc.cordial.com/"
        let accountKey = "cordialdev"
        let channelKey = "push"
        let qtyCachedEventQueue = 100
        
        return Credentials(baseURL: baseURL, accountKey: accountKey, channelKey: channelKey, qtyCachedEventQueue: qtyCachedEventQueue)
    }
}

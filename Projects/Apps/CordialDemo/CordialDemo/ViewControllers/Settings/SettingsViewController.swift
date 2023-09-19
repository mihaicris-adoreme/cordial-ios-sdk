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

    @IBOutlet weak var eventsStreamURLTextField: UITextField!
    @IBOutlet weak var messageHubURLTextField: UITextField!
    @IBOutlet weak var accountKeyTextField: UITextField!
    @IBOutlet weak var channelKeyTextField: UITextField!
    @IBOutlet weak var pushNotificationsCategoriesSwitch: UISwitch!
    @IBOutlet weak var qtyCachedEventQueueTextField: UITextField!
    @IBOutlet weak var eventsBulkSizeTextField: UITextField!
    @IBOutlet weak var eventsBulkUploadIntervalTextField: UITextField!
    @IBOutlet weak var inboxMaxCacheSizeTextField: UITextField!
    @IBOutlet weak var inboxMaxCachableMessageSizeTextField: UITextField!
    
    let cordialAPI = CordialAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.eventsStreamURLTextField.text = self.cordialAPI.getEventsStreamURL()
        self.messageHubURLTextField.text = self.cordialAPI.getMessageHubURL()
        self.accountKeyTextField.text = self.cordialAPI.getAccountKey()
        self.channelKeyTextField.text = self.cordialAPI.getChannelKey()
        self.qtyCachedEventQueueTextField.text = String(CordialApiConfiguration.shared.qtyCachedEventQueue)
        self.eventsBulkSizeTextField.text = String(CordialApiConfiguration.shared.eventsBulkSize)
        self.eventsBulkUploadIntervalTextField.text = String(Int(CordialApiConfiguration.shared.eventsBulkUploadInterval))
        self.inboxMaxCacheSizeTextField.text = String(CordialApiConfiguration.shared.inboxMessageCache.maxCacheSize)
        self.inboxMaxCachableMessageSizeTextField.text = String(CordialApiConfiguration.shared.inboxMessageCache.maxCachableMessageSize)
        
        self.pushNotificationsCategoriesSwitch.setOn(App.getNotificationCategoriesIsEducational(), animated: false)
        
        self.updateSettingsPage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.saveSettingsData()
    }
    
    @IBAction func pushNotificationsCategoriesSwitchAction(_ sender: UISwitch) {
        App.setNotificationCategoriesIsEducational(sender.isOn)
    }
    
    @IBAction func choosePresetAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Settings", message: "Choose Preset", preferredStyle: .actionSheet)

        let qcAction = UIAlertAction(title: Settings.qc.rawValue, style: .default) { action in
            App.setSettingsType(settingsType: Settings.qc.rawValue)
            
            self.updateSettingsPage()
        }
        
        let stagingAction = UIAlertAction(title: Settings.staging.rawValue, style: .default) { action in
            App.setSettingsType(settingsType: Settings.staging.rawValue)
            
            self.updateSettingsPage()
        }
        
        let prodAction = UIAlertAction(title: Settings.production.rawValue, style: .default) { action in
            App.setSettingsType(settingsType: Settings.production.rawValue)
            
            self.updateSettingsPage()
        }
        
        let usWest2 = UIAlertAction(title: Settings.usWest2.rawValue, style: .default) { action in
            App.setSettingsType(settingsType: Settings.usWest2.rawValue)
            
            self.updateSettingsPage()
        }
        
        let customAction = UIAlertAction(title: Settings.custom.rawValue, style: .default) { action in
            App.setSettingsType(settingsType: Settings.custom.rawValue)
            
            self.updateSettingsPage()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(qcAction)
        alertController.addAction(stagingAction)
        alertController.addAction(prodAction)
        alertController.addAction(usWest2)
        alertController.addAction(customAction)
        alertController.addAction(cancelAction)

        // iPadOS presentation
        if let presenter = alertController.popoverPresentationController {
            let button = sender as UIView
            
            presenter.sourceView = button
            presenter.sourceRect = button.bounds
        }
        
        self.present(alertController, animated: true, completion: nil)

    }
    
    func saveSettingsData() {
        if let eventsStreamURL = self.eventsStreamURLTextField.text,
           let messageHubURL = self.messageHubURLTextField.text,
           let accountKey = self.accountKeyTextField.text,
           let channelKey = self.channelKeyTextField.text,
           let qtyCachedEventQueueString = self.qtyCachedEventQueueTextField.text,
           let qtyCachedEventQueue = Int(qtyCachedEventQueueString),
           let eventsBulkSizeString = self.eventsBulkSizeTextField.text,
           let eventsBulkSize = Int(eventsBulkSizeString),
           let eventsBulkUploadIntervalString = self.eventsBulkUploadIntervalTextField.text,
           let eventsBulkUploadInterval = TimeInterval(eventsBulkUploadIntervalString),
           let maxCacheSizeString = self.inboxMaxCacheSizeTextField.text,
           let maxCacheSize = Int(maxCacheSizeString),
           let maxCachableMessageSizeString = self.inboxMaxCachableMessageSizeTextField.text,
           let maxCachableMessageSize = Int(maxCachableMessageSizeString) {
            
            App.setAccountKey(accountKey: accountKey)
            App.setChannelKey(channelKey: channelKey)
            App.setEventsStreamURL(eventsStreamURL: eventsStreamURL)
            App.setMessageHubURL(messageHubURL: messageHubURL)
            
            CordialApiConfiguration.shared.initialize(accountKey: accountKey, channelKey: channelKey, eventsStreamURL: eventsStreamURL, messageHubURL: messageHubURL)
            
            CordialApiConfiguration.shared.qtyCachedEventQueue = abs(qtyCachedEventQueue)
            CordialApiConfiguration.shared.eventsBulkSize = abs(eventsBulkSize)
            CordialApiConfiguration.shared.eventsBulkUploadInterval = abs(eventsBulkUploadInterval)
            CordialApiConfiguration.shared.inboxMessageCache.maxCacheSize = abs(maxCacheSize)
            CordialApiConfiguration.shared.inboxMessageCache.maxCachableMessageSize = abs(maxCachableMessageSize)
        }
    }
    
    func updateSettingsPage() {
        switch App.getSettingsType() {
        case Settings.qc.rawValue:
            self.title = Settings.qc.rawValue
            
            let qcSettings = self.getQCSettings()
            
            self.eventsStreamURLTextField.text = qcSettings.eventsStreamURL
            self.messageHubURLTextField.text = qcSettings.messageHubURL
            self.accountKeyTextField.text = qcSettings.accountKey
            self.channelKeyTextField.text = qcSettings.channelKey
            
            self.disableEditing()
        case Settings.staging.rawValue:
            self.title = Settings.staging.rawValue
            
            let stagingSettings = self.getStagingSettings()
            
            self.eventsStreamURLTextField.text = stagingSettings.eventsStreamURL
            self.messageHubURLTextField.text = stagingSettings.messageHubURL
            self.accountKeyTextField.text = stagingSettings.accountKey
            self.channelKeyTextField.text = stagingSettings.channelKey
            
            self.disableEditing()
        case Settings.production.rawValue:
            self.title = Settings.production.rawValue
            
            let productionSettings = self.getProductionSettings()
            
            self.eventsStreamURLTextField.text = productionSettings.eventsStreamURL
            self.messageHubURLTextField.text = productionSettings.messageHubURL
            self.accountKeyTextField.text = productionSettings.accountKey
            self.channelKeyTextField.text = productionSettings.channelKey
            
            self.disableEditing()
        case Settings.usWest2.rawValue:
            self.title = Settings.usWest2.rawValue
            
            let usWest2Settings = self.getUSWest2Settings()
            
            self.eventsStreamURLTextField.text = usWest2Settings.eventsStreamURL
            self.messageHubURLTextField.text = usWest2Settings.messageHubURL
            self.accountKeyTextField.text = usWest2Settings.accountKey
            self.channelKeyTextField.text = usWest2Settings.channelKey
            
            self.disableEditing()
        default:
            self.title = Settings.custom.rawValue
            
            self.enableEditing()
        }
    }
    
    func getQCSettings() -> Credentials {
        let eventsStreamURL = "https://events-stream-svc.cordial-core.mobile-sdk-1-12-2.cordialdev.com/"
        let messageHubURL = "https://message-hub-svc.cordial-core.mobile-sdk-1-12-2.cordialdev.com/"
        let accountKey = "qc-all-channels-cID-pk"
        let channelKey = "push"
        
        return Credentials(eventsStreamURL: eventsStreamURL, messageHubURL: messageHubURL, accountKey: accountKey, channelKey: channelKey)
    }
    
    func getStagingSettings() -> Credentials {
        let eventsStreamURL = "https://events-stream-svc.stg.cordialdev.com/"
        let messageHubURL = "https://message-hub-svc.stg.cordialdev.com/"
        let accountKey = "stgtaras"
        let channelKey = "sdk"
        
        return Credentials(eventsStreamURL: eventsStreamURL, messageHubURL: messageHubURL, accountKey: accountKey, channelKey: channelKey)
    }
    
    func getProductionSettings() -> Credentials {
        let eventsStreamURL = "https://events-stream-svc.cordial.com/"
        let messageHubURL = "https://message-hub-svc.cordial.com/"
        let accountKey = "cordialdev"
        let channelKey = "push"
        
        return Credentials(eventsStreamURL: eventsStreamURL, messageHubURL: messageHubURL, accountKey: accountKey, channelKey: channelKey)
    }
    
    func getUSWest2Settings() -> Credentials {
        let eventsStreamURL = "https://events-stream-svc.usw2.cordial.com/"
        let messageHubURL = "https://message-hub-svc.usw2.cordial.com/"
        let accountKey = "dev2"
        let channelKey = "push"
        
        return Credentials(eventsStreamURL: eventsStreamURL, messageHubURL: messageHubURL, accountKey: accountKey, channelKey: channelKey)
    }
    
    func enableEditing() {
        self.eventsStreamURLTextField.isUserInteractionEnabled = true
        self.messageHubURLTextField.isUserInteractionEnabled = true
        self.accountKeyTextField.isUserInteractionEnabled = true
        self.channelKeyTextField.isUserInteractionEnabled = true
        self.qtyCachedEventQueueTextField.isUserInteractionEnabled = true
        self.eventsBulkSizeTextField.isUserInteractionEnabled = true
        self.eventsBulkUploadIntervalTextField.isUserInteractionEnabled = true
        self.inboxMaxCacheSizeTextField.isUserInteractionEnabled = true
        self.inboxMaxCachableMessageSizeTextField.isUserInteractionEnabled = true
        
        self.eventsStreamURLTextField.textColor = .darkGray
        self.messageHubURLTextField.textColor = .darkGray
        self.accountKeyTextField.textColor = .darkGray
        self.channelKeyTextField.textColor = .darkGray
        self.qtyCachedEventQueueTextField.textColor = .darkGray
        self.eventsBulkSizeTextField.textColor = .darkGray
        self.eventsBulkUploadIntervalTextField.textColor = .darkGray
        self.inboxMaxCacheSizeTextField.textColor = .darkGray
        self.inboxMaxCachableMessageSizeTextField.textColor = .darkGray
        
        self.eventsStreamURLTextField.setBottomBorder(color: .black)
        self.messageHubURLTextField.setBottomBorder(color: .black)
        self.accountKeyTextField.setBottomBorder(color: .black)
        self.channelKeyTextField.setBottomBorder(color: .black)
        self.qtyCachedEventQueueTextField.setBottomBorder(color: .black)
        self.eventsBulkSizeTextField.setBottomBorder(color: .black)
        self.eventsBulkUploadIntervalTextField.setBottomBorder(color: .black)
        self.inboxMaxCacheSizeTextField.setBottomBorder(color: .black)
        self.inboxMaxCachableMessageSizeTextField.setBottomBorder(color: .black)
    }
    
    func disableEditing() {
        self.eventsStreamURLTextField.isUserInteractionEnabled = false
        self.messageHubURLTextField.isUserInteractionEnabled = false
        self.accountKeyTextField.isUserInteractionEnabled = false
        self.channelKeyTextField.isUserInteractionEnabled = false
        self.qtyCachedEventQueueTextField.isUserInteractionEnabled = false
        self.eventsBulkSizeTextField.isUserInteractionEnabled = false
        self.eventsBulkUploadIntervalTextField.isUserInteractionEnabled = false
        self.inboxMaxCacheSizeTextField.isUserInteractionEnabled = false
        self.inboxMaxCachableMessageSizeTextField.isUserInteractionEnabled = false
        
        self.eventsStreamURLTextField.textColor = .lightGray
        self.messageHubURLTextField.textColor = .lightGray
        self.accountKeyTextField.textColor = .lightGray
        self.channelKeyTextField.textColor = .lightGray
        self.qtyCachedEventQueueTextField.textColor = .lightGray
        self.eventsBulkSizeTextField.textColor = .lightGray
        self.eventsBulkUploadIntervalTextField.textColor = .lightGray
        self.inboxMaxCacheSizeTextField.textColor = .lightGray
        self.inboxMaxCachableMessageSizeTextField.textColor = .lightGray
        
        self.eventsStreamURLTextField.setBottomBorder(color: .lightGray)
        self.messageHubURLTextField.setBottomBorder(color: .lightGray)
        self.accountKeyTextField.setBottomBorder(color: .lightGray)
        self.channelKeyTextField.setBottomBorder(color: .lightGray)
        self.qtyCachedEventQueueTextField.setBottomBorder(color: .lightGray)
        self.eventsBulkSizeTextField.setBottomBorder(color: .lightGray)
        self.eventsBulkUploadIntervalTextField.setBottomBorder(color: .lightGray)
        self.inboxMaxCacheSizeTextField.setBottomBorder(color: .lightGray)
        self.inboxMaxCachableMessageSizeTextField.setBottomBorder(color: .lightGray)
    }
}

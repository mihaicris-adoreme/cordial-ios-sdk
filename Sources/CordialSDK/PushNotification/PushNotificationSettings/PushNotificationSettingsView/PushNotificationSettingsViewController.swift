//
//  PushNotificationSettingsViewController.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 22.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class PushNotificationSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var rows = InternalCordialAPI().getPushNotificationSettings()
    
    let pushNotificationSettingsHandler = PushNotificationSettingsHandler.shared

    let tableView = PushNotificationSettingsTableView(frame: UIScreen.main.nativeBounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UITableView
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.backgroundColor = self.pushNotificationSettingsHandler.tableViewBackgroundColor
        self.tableView.separatorColor = self.pushNotificationSettingsHandler.tableViewBackgroundColor
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(PushNotificationSettingsTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.allowsSelection = false
        
        // Configuration
        let wrapTableView = UIView(frame: self.view.frame)
        wrapTableView.backgroundColor = self.pushNotificationSettingsHandler.tableViewBackgroundColor
  
        wrapTableView.addSubview(self.tableView)
        
        let views = ["tableView": self.tableView]

        if API.isDeviceSmallScreen() {
            wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views))
            wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: views))
        } else {
            wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[tableView]-20-|", options: [], metrics: nil, views: views))
            wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[tableView]-20-|", options: [], metrics: nil, views: views))
        }
        
        self.view.addSubview(wrapTableView)
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        let row = self.rows[sender.tag]
        
        let key = row.key
        let name = row.name
        let initState = sender.isOn
        
        self.rows[sender.tag] = PushNotificationSettings(key: key, name: name, initState: initState)
        
        InternalCordialAPI().setPushNotificationSettings(pushNotificationSettings: self.rows)
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PushNotificationSettingsTableViewCell
        
        let settings = self.rows[indexPath.row]
        
        cell.title.text = "\(settings.name)"
        cell.title.textColor = self.pushNotificationSettingsHandler.tableViewCellTitleColor
        
        cell.switcher.isOn = settings.initState
        cell.switcher.tag = indexPath.row // for detect which row switch changed
        cell.switcher.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        
        cell.switcher.thumbTintColor = self.pushNotificationSettingsHandler.tableViewCellSwitchThumbColor
        
        cell.switcher.tintColor = self.pushNotificationSettingsHandler.tableViewCellSwitchOnColor
        cell.switcher.onTintColor = self.pushNotificationSettingsHandler.tableViewCellSwitchOnColor
        
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = self.pushNotificationSettingsHandler.tableViewCellBackgroundColor
        
        let cornerRadius: CGFloat = 10
        
        switch indexPath.row {
        case 0:
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case self.rows.count - 1:
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        default:
            cell.layer.cornerRadius = 0
        }
    }
}

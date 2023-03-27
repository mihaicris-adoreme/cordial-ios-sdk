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
    
    var options: UNAuthorizationOptions = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let margin = 20.0
        let fontSize = 17.0
        
        let width = self.view.frame.size.width - margin * 2
        let height = self.view.frame.size.height / 4
        
        // UITableView
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.backgroundColor = self.pushNotificationSettingsHandler.tableViewBackgroundColor
        self.tableView.separatorColor = self.pushNotificationSettingsHandler.tableViewBackgroundColor
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(PushNotificationSettingsTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.allowsSelection = false
        self.tableView.bounces = false
        
        // UITableView - HeaderView
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        let upperLabel = PushNotificationSettingsViewLabel(frame: CGRect(x: 0, y: 0, width: width, height: height), fontSize: fontSize)
        upperLabel.textColor = UIColor.white
        upperLabel.text = "Upper Label"
        
        tableHeaderView.addSubview(upperLabel)
        self.tableView.tableHeaderView = tableHeaderView
        
        // UITableView - FooterView
        let tableFooterView = PushNotificationSettingsViewFooterView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        let bottomLabel = PushNotificationSettingsViewLabel(frame: CGRect(x: 0, y: 0, width: width, height: height), fontSize: fontSize)
        bottomLabel.textColor = UIColor.white
        bottomLabel.text = "Bottom Label"
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: height, width: width, height: height / 3)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = bottomLabel.font
        button.layer.masksToBounds = true
        button.setTitle("Enable Notifications", for: .normal)
        button.backgroundColor = UIColor.red
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        
        let buttonLabelButton = UIButton(type: .system)
        buttonLabelButton.frame = CGRect(x: 0, y: button.frame.height + height, width: width, height: height / 4)
        buttonLabelButton.setTitleColor(UIColor.red, for: .normal)
        buttonLabelButton.titleLabel?.font = bottomLabel.font
        buttonLabelButton.layer.masksToBounds = true
        buttonLabelButton.setTitle("Not now", for: .normal)
        buttonLabelButton.addTarget(self, action: #selector(self.buttonLabelButtonTapped(_:)), for: .touchUpInside)
                
        tableFooterView.addSubview(bottomLabel)
        tableFooterView.addSubview(button)
        tableFooterView.addSubview(buttonLabelButton)
        self.tableView.tableFooterView = tableFooterView
        
        // UITableView - Configuration
        let wrapView = UIView(frame: self.view.frame)
        wrapView.backgroundColor = self.pushNotificationSettingsHandler.tableViewBackgroundColor
  
        wrapView.addSubview(self.tableView)
        
        let wrapViews = ["tableView": self.tableView]

        wrapView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(margin)-[tableView]-\(margin)-|", options: [], metrics: nil, views: wrapViews))
        wrapView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: wrapViews))
        
        self.view.addSubview(wrapView)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        print("Button Tapped")
    }
    
    @objc func buttonLabelButtonTapped(_ sender: UIButton) {
        print("Button Label Tapped")
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

//
//  PushNotificationSettingsTableViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 02.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class PushNotificationSettingsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: PushNotificationSettingsTableView!
    
    private var sections: [PushNotificationSettingsTableData] = [
        PushNotificationSettingsTableData(title: "NAVIGATION BAR", data: [
            PushNotificationSettingsData(title: "Background color", color: PushNotificationSettingsHandler.shared.navigationBarBackgroundColor),
            PushNotificationSettingsData(title: "Title color", color: PushNotificationSettingsHandler.shared.navigationBarTitleColor),
            PushNotificationSettingsData(title: "Xmark color", color: PushNotificationSettingsHandler.shared.navigationBarXmarkColor)
        ]),
        PushNotificationSettingsTableData(title: "TABLE VIEW", data: [
            PushNotificationSettingsData(title: "Background color", color: PushNotificationSettingsHandler.shared.tableViewBackgroundColor),
            PushNotificationSettingsData(title: "Section title color", color: PushNotificationSettingsHandler.shared.tableViewSectionTitleColor),
            PushNotificationSettingsData(title: "Cell background color", color: PushNotificationSettingsHandler.shared.tableViewCellBackgroundColor),
            PushNotificationSettingsData(title: "Cell title color", color: PushNotificationSettingsHandler.shared.tableViewCellTitleColor),
            PushNotificationSettingsData(title: "Cell switch on color", color: PushNotificationSettingsHandler.shared.tableViewCellSwitchOnColor),
            PushNotificationSettingsData(title: "Cell switch thumb color", color: PushNotificationSettingsHandler.shared.tableViewCellSwitchThumbColor)
        ])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UITableView
        self.tableView.showsVerticalScrollIndicator = false
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(PushNotificationSettingsTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configuration
        let wrapTableView = UIView(frame: self.view.frame)
  
        if let tableView = self.tableView {
            wrapTableView.addSubview(tableView)
            
            let views = ["tableView": tableView]

            wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views))
            wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: views))
            
            self.view.addSubview(wrapTableView)
        } else {
            self.dismiss(animated: false)
        }
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].data.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PushNotificationSettingsTableViewCell
                
        let settings = self.sections[indexPath.section].data[indexPath.row]
        
        cell.title.text = "\(settings.title)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius: CGFloat = 10
        
        switch indexPath.row {
        case 0:
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case self.sections[indexPath.section].data.count - 1:
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        default:
            cell.layer.cornerRadius = 0
        }
    }
}

//
//  PushNotificationSettingsTableViewController.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 01.02.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class PushNotificationSettingsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let sections = ["PUSH NOTIFICATIONS FILTER"]
    private let rows = [CordialApiConfiguration.shared.pushNotificationSettings]
    
    var tableView: UITableView!
    
    let tableViewBackgroundColor = UIColor.systemGray
    let tableViewCellBackgroundColor = UIColor.lightGray
    let tableViewCellTextBackgroundColor = UIColor.darkGray
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(self.dismissViewController))
        
        self.tableView = PushNotificationSettingsTableView(frame: CGRect(x: 20, y: 0, width: self.view.bounds.width - 40, height: self.view.bounds.size.height))
        self.tableView.backgroundColor = self.tableViewBackgroundColor
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(PushNotificationSettingsTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.allowsSelection = false
        self.tableView.bounces = false
        
        let wrapTableView = UIView(frame: self.view.bounds)
        wrapTableView.backgroundColor = self.tableViewBackgroundColor
        
        wrapTableView.addSubview(self.tableView)
        self.view.addSubview(wrapTableView)
    }

    @objc func dismissViewController() {
        self.dismiss(animated: true)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows[section].count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PushNotificationSettingsTableViewCell
        
        cell.title.text = "\(self.rows[indexPath.section][indexPath.row])"
        cell.title.textColor = self.tableViewCellTextBackgroundColor
        
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = self.tableViewCellBackgroundColor
        
        let cornerRadius: CGFloat = 10
        
        switch indexPath.row {
        case 0:
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, ]
        case self.rows[indexPath.section].count - 1:
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        default:
            cell.layer.cornerRadius = 0
        }
    }
    
}

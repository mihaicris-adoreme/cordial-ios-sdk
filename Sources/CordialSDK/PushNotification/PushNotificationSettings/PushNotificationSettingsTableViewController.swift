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
    let tableViewCellTextColor = UIColor.lightText
    let navigationBarTextColor = UIColor.darkGray
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UINavigationBar
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: UINavigationController().navigationBar.frame.size.height))
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.tintColor = self.navigationBarTextColor
        navigationBar.barTintColor = self.tableViewBackgroundColor
        
        let navigationItem = UINavigationItem(title: "Notifications")
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(self.dismissViewController))
        navigationItem.leftBarButtonItem = doneItem
        navigationBar.setItems([navigationItem], animated: false)
        
        // UITableView
        self.tableView = PushNotificationSettingsTableView(frame: self.view.frame)
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.backgroundColor = self.tableViewBackgroundColor
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(PushNotificationSettingsTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.allowsSelection = false
        
        // Configuration
        let wrapTableView = UIView(frame: self.view.frame)
        wrapTableView.backgroundColor = self.tableViewBackgroundColor
  
        if let tableView = self.tableView {
            wrapTableView.addSubview(tableView)
            wrapTableView.addSubview(navigationBar)
            
            let views = ["tableView": tableView, "navigationBar": navigationBar]

            wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[navigationBar]|", options: [], metrics: nil, views: views))
            wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[tableView]-20-|", options: [], metrics: nil, views: views))
            wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[navigationBar]-[tableView]-20-|", options: [], metrics: nil, views: views))
            
            self.view.addSubview(wrapTableView)
        } else {
            self.dismiss(animated: false)
        }
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
        cell.title.textColor = self.tableViewCellTextColor
        
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

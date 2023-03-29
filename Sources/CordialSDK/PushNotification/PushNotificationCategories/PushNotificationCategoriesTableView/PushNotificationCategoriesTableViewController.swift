//
//  PushNotificationCategoriesTableViewController.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 01.02.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class PushNotificationCategoriesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let section = "PUSH NOTIFICATIONS FILTER"
    private var rows = InternalCordialAPI().getPushNotificationCategories()
    
    let pushNotificationCategoriesHandler = PushNotificationCategoriesHandler.shared

    let tableView = PushNotificationCategoriesTableView(frame: UIScreen.main.nativeBounds)
    let navigationBar = UINavigationBar(frame: UINavigationController().navigationBar.frame)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UINavigationBar
        self.navigationBar.translatesAutoresizingMaskIntoConstraints = false
        self.navigationBar.tintColor = self.pushNotificationCategoriesHandler.navigationBarXmarkColor
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = self.pushNotificationCategoriesHandler.navigationBarBackgroundColor
        
        let navigationItem = UINavigationItem(title: "Notifications")
        self.navigationBar.titleTextAttributes = [.foregroundColor: self.pushNotificationCategoriesHandler.navigationBarTitleColor]
    
        let dismissItem: UIBarButtonItem?
        if #available(iOS 13.0, *) {
            dismissItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: #selector(self.dismissViewController))
        } else {
            dismissItem = UIBarButtonItem(title: "X", style: .plain, target: nil, action: #selector(self.dismissViewController))
            dismissItem?.setTitleTextAttributes([
                .font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.5),
                .foregroundColor: self.pushNotificationCategoriesHandler.navigationBarXmarkColor
            ], for: .normal)
        }
        
        navigationItem.leftBarButtonItem = dismissItem
        self.navigationBar.setItems([navigationItem], animated: false)
        
        // UITableView
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.backgroundColor = self.pushNotificationCategoriesHandler.tableViewBackgroundColor
        self.tableView.separatorColor = self.pushNotificationCategoriesHandler.tableViewBackgroundColor
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(PushNotificationCategoriesTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.allowsSelection = false
        
        // Configuration
        let wrapTableView = UIView(frame: self.view.frame)
        wrapTableView.backgroundColor = self.pushNotificationCategoriesHandler.tableViewBackgroundColor
  
        wrapTableView.addSubview(self.tableView)
        wrapTableView.addSubview(self.navigationBar)
        
        let views = ["tableView": self.tableView, "navigationBar": self.navigationBar]

        wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[navigationBar]|", options: [], metrics: nil, views: views))
        wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[tableView]-20-|", options: [], metrics: nil, views: views))
        wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[navigationBar]-[tableView]-20-|", options: [], metrics: nil, views: views))
        
        self.view.addSubview(wrapTableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CordialPushNotification.shared.isScreenPushNotificationCategoriesShown = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        CordialPushNotification.shared.isScreenPushNotificationCategoriesShown = false
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true)
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        let row = self.rows[sender.tag]
        
        let key = row.key
        let name = row.name
        let initState = sender.isOn
        
        self.rows[sender.tag] = PushNotificationCategory(key: key, name: name, initState: initState)
        
        InternalCordialAPI().setPushNotificationCategories(pushNotificationCategories: self.rows)
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PushNotificationCategoriesTableViewCell
        
        let row = self.rows[indexPath.row]
        
        cell.title.text = "\(row.name)"
        cell.title.textColor = self.pushNotificationCategoriesHandler.tableViewCellTitleColor
        
        cell.switcher.isOn = row.initState
        cell.switcher.tag = indexPath.row // for detect which row switch changed
        cell.switcher.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        
        cell.switcher.thumbTintColor = self.pushNotificationCategoriesHandler.tableViewCellSwitchThumbColor
        
        cell.switcher.tintColor = self.pushNotificationCategoriesHandler.tableViewCellSwitchOnColor
        cell.switcher.onTintColor = self.pushNotificationCategoriesHandler.tableViewCellSwitchOnColor
        
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = self.pushNotificationCategoriesHandler.tableViewCellBackgroundColor
        
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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = self.pushNotificationCategoriesHandler.tableViewSectionTitleColor
        header.textLabel?.textAlignment = .left
    }
}

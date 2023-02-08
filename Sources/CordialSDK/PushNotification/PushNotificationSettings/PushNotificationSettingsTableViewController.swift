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
    
    let tableViewBackgroundColor = UIColor(red: 33/255, green: 36/255, blue: 41/255, alpha: 1)
    let tableViewCellBackgroundColor = UIColor(red: 26/255, green: 29/255, blue: 35/255, alpha: 1)
    let tableViewCellTextColor = UIColor(red: 232/255, green: 233/255, blue: 238/255, alpha: 1)
    let tableViewHeaderTextColor = UIColor(red: 166/255, green: 167/255, blue: 172/255, alpha: 1)

    let navigationBarBackgroundColor = UIColor(red: 26/255, green: 29/255, blue: 35/255, alpha: 1)
    let navigationBarTextColor = UIColor(red: 211/255, green: 212/255, blue: 217/255, alpha: 1)
    let navigationBarXmarkColor = UIColor(red: 211/255, green: 212/255, blue: 217/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UINavigationBar
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: UINavigationController().navigationBar.frame.size.height))
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.tintColor = self.navigationBarXmarkColor
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = self.navigationBarBackgroundColor
        
        let navigationItem = UINavigationItem(title: "Notifications")
        navigationBar.titleTextAttributes = [.foregroundColor: self.navigationBarTextColor]
    
        let dismissItem: UIBarButtonItem?
        if #available(iOS 13.0, *) {
            dismissItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: #selector(self.dismissViewController))
        } else {
            dismissItem = UIBarButtonItem(title: "X", style: .plain, target: nil, action: #selector(self.dismissViewController))
            dismissItem?.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.5), .foregroundColor: self.navigationBarXmarkColor], for: .normal)
        }
        
        navigationItem.leftBarButtonItem = dismissItem
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

            if API.isDeviceSmallScreen() {
                wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[navigationBar]|", options: [], metrics: nil, views: views))
                wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views))
                wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[navigationBar]-[tableView]|", options: [], metrics: nil, views: views))
            } else {
                wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[navigationBar]|", options: [], metrics: nil, views: views))
                wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[tableView]-20-|", options: [], metrics: nil, views: views))
                wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[navigationBar]-[tableView]-20-|", options: [], metrics: nil, views: views))
            }
            
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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = self.tableViewHeaderTextColor
    }
    
}

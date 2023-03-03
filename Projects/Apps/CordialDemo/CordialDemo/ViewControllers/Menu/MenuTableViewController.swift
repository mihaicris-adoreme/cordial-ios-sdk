//
//  MenuTableViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 02.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class MenuTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let sections = [""]
    private var rows: [[Menu]] = []
    
    internal var navigationBarBackgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
    internal var navigationBarTitleColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    internal var navigationBarXmarkColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    
    internal var tableViewBackgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
    internal var tableViewSectionTitleColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    
    internal var tableViewSectionCellBackgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    internal var tableViewSectionCellTitleColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    
    internal var tableViewSectionCellSwitchOnTintColor = UIColor.systemGreen
    internal var tableViewSectionCellSwitchThumbTintColor = UIColor.white
    
    var tableView: UITableView!
    
    var menu: [Menu] = [
        Menu(title: "Profile", key: "to_profile"),
        Menu(title: "Send Custom Event", key: "to_custom_event"),
        Menu(title: "Inbox", key: "to_inbox"),
        Menu(title: "Notification Settings", key: "to_notification_settings"),
        Menu(title: "Log in", key: "to_login"),
        Menu(title: "Log out", key: "to_logout")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rows.append(self.menu)
        
        // UINavigationBar
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: UINavigationController().navigationBar.frame.size.height))
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.tintColor = self.navigationBarXmarkColor
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = self.navigationBarBackgroundColor
        
        let navigationItem = UINavigationItem(title: "Notifications")
        navigationBar.titleTextAttributes = [.foregroundColor: self.navigationBarTitleColor]
    
        let dismissItem: UIBarButtonItem?
        if #available(iOS 13.0, *) {
            dismissItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: #selector(self.dismissViewController))
        } else {
            dismissItem = UIBarButtonItem(title: "X", style: .plain, target: nil, action: #selector(self.dismissViewController))
            dismissItem?.setTitleTextAttributes([
                .font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.5),
                .foregroundColor: self.navigationBarXmarkColor
            ], for: .normal)
        }
        
        navigationItem.leftBarButtonItem = dismissItem
        navigationBar.setItems([navigationItem], animated: false)
        
        // UITableView
        self.tableView = MenuTableView(frame: self.view.frame)
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.backgroundColor = self.tableViewBackgroundColor
        self.tableView.separatorColor = self.tableView.backgroundColor
        
        self.tableView.rowHeight = UINavigationController().navigationBar.frame.size.height * 1.2
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(MenuTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configuration
        let wrapTableView = UIView(frame: self.view.frame)
        wrapTableView.backgroundColor = self.tableViewBackgroundColor
  
        if let tableView = self.tableView {
            wrapTableView.addSubview(tableView)
            wrapTableView.addSubview(navigationBar)
            
            let views = ["tableView": tableView, "navigationBar": navigationBar]

            if App.isDeviceSmallScreen() {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MenuTableViewCell
                
        let settings = self.rows[indexPath.section][indexPath.row]
        
        cell.title.text = "\(settings.title)"
        cell.title.textColor = self.tableViewSectionCellTitleColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = self.tableViewSectionCellBackgroundColor
        
        cell.layer.borderColor = self.tableViewBackgroundColor.cgColor
        cell.layer.borderWidth = 1
        
        let cornerRadius: CGFloat = 10
        
        switch indexPath.row {
        case 0:
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case self.rows[indexPath.section].count - 1:
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        default:
            cell.layer.cornerRadius = 0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = self.tableViewSectionTitleColor
    }
}

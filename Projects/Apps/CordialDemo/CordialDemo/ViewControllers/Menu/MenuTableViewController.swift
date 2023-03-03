//
//  MenuTableViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 02.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class MenuTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let menu: [Menu] = [
        Menu(title: "Profile", key: "to_profile"),
        Menu(title: "Send Custom Event", key: "to_custom_event"),
        Menu(title: "Inbox", key: "to_inbox"),
        Menu(title: "Notification Settings", key: "to_notification_settings"),
        Menu(title: "Log in", key: "to_login"),
        Menu(title: "Log out", key: "to_logout")
    ]
    
    let navigationBarBackgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
    let navigationBarXmarkColor = UIColor(red: 135/255, green: 135/255, blue: 135/255, alpha: 1)
    
    let tableViewBackgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)

    let tableViewCellBackgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    let tableViewCellTitleColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = self.view.frame.width
        let height = UINavigationController().navigationBar.frame.size.height
        
        // UINavigationBar
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.tintColor = self.navigationBarXmarkColor
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = self.navigationBarBackgroundColor
    
        let dismissItem: UIBarButtonItem?
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold, scale: .large)
            let image = UIImage(systemName: "xmark.circle", withConfiguration: config)
            dismissItem = UIBarButtonItem(image: image, style: .plain, target: nil, action: #selector(self.dismissViewController))
        } else {
            dismissItem = UIBarButtonItem(title: "X", style: .plain, target: nil, action: #selector(self.dismissViewController))
            dismissItem?.setTitleTextAttributes([
                .font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.5),
                .foregroundColor: self.navigationBarXmarkColor
            ], for: .normal)
        }
        
        let appIcon = UIApplication.shared.icon?.round(15).withRenderingMode(.alwaysOriginal)
        let appIconItem = UIBarButtonItem(image: appIcon, style: .done, target: nil, action: nil)
        
        navigationItem.rightBarButtonItem = dismissItem
        navigationItem.leftBarButtonItem = appIconItem
        navigationBar.setItems([navigationItem], animated: false)
        
        // UITableView
        self.tableView = MenuTableView(frame: self.view.frame)
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.backgroundColor = self.tableViewBackgroundColor
        self.tableView.separatorColor = self.tableViewBackgroundColor
        
        self.tableView.rowHeight = height * 1.2
        
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

            wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[navigationBar]|", options: [], metrics: nil, views: views))
            wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[tableView]-20-|", options: [], metrics: nil, views: views))
            wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[navigationBar][tableView]|", options: [], metrics: nil, views: views))
            
            self.view.addSubview(wrapTableView)
        } else {
            self.dismiss(animated: false)
        }
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true)
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MenuTableViewCell
                
        let settings = self.menu[indexPath.row]
        
        cell.title.text = "\(settings.title)"
        cell.title.textColor = self.tableViewCellTitleColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = self.tableViewCellBackgroundColor
        
        cell.layer.borderColor = self.tableViewBackgroundColor.cgColor
        cell.layer.borderWidth = 1
        
        let cornerRadius: CGFloat = 10
        
        switch indexPath.row {
        case 0:
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case self.menu.count - 1:
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        default:
            cell.layer.cornerRadius = 0
        }
    }
}

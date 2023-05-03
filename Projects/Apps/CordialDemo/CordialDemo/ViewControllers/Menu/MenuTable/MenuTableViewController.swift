//
//  MenuTableViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 02.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class MenuTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var sender: UIViewController!
    var tableView: UITableView!
    
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
    
        let navigationItem = UINavigationItem(title: String())
        
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
        switch self.sender {
        case is CatalogCollectionViewController:
            let catalogCollectionViewController = self.sender as! CatalogCollectionViewController
            
            self.dismissViewController()
            
            switch self.menu[indexPath.row].key {
            case "to_profile":
                let identifier = catalogCollectionViewController.segueToProfileIdentifier
                catalogCollectionViewController.performSegue(withIdentifier: identifier, sender: self)
            case "to_custom_event":
                let identifier = catalogCollectionViewController.segueToCustomEventIdentifier
                catalogCollectionViewController.performSegue(withIdentifier: identifier, sender: self)
            case "to_inbox":
                let alert = UIAlertController(title: "Inbox", message: "Please select the view", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "List", style: .default) { action in
                    let identifier = catalogCollectionViewController.segueToInboxTableListIdentifier
                    catalogCollectionViewController.performSegue(withIdentifier: identifier, sender: self)
                })
                
                alert.addAction(UIAlertAction(title: "Cards", style: .default) { action in
                    let identifier = catalogCollectionViewController.segueToInboxCollectionIdentifier
                    catalogCollectionViewController.performSegue(withIdentifier: identifier, sender: self)
                })
                
                alert.addAction(UIAlertAction(title: "Raw", style: .default) { action in
                    let identifier = catalogCollectionViewController.segueToInboxTableIdentifier
                    catalogCollectionViewController.performSegue(withIdentifier: identifier, sender: self)
                })
                
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                
                catalogCollectionViewController.present(alert, animated: true)
            case "to_notification_settings":
                let identifier = catalogCollectionViewController.segueToPushNotificationSettings
                catalogCollectionViewController.performSegue(withIdentifier: identifier, sender: self)
            case "to_login":
                catalogCollectionViewController.loginAction()
            case "to_logout":
                catalogCollectionViewController.logoutAction()
            default:
                break
            }
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = self.tableViewCellBackgroundColor
        
        let cornerRadius: CGFloat = 10
        let verticalPadding: CGFloat = 1
        
        switch indexPath.row {
        case 0:
            let maskLayer = CALayer()
            maskLayer.cornerRadius = cornerRadius
            maskLayer.backgroundColor = UIColor.black.cgColor
            maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding / 2)
            maskLayer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            cell.layer.mask = maskLayer
        case self.menu.count - 1:
            let maskLayer = CALayer()
            maskLayer.cornerRadius = cornerRadius
            maskLayer.backgroundColor = UIColor.black.cgColor
            maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding / 2)
            maskLayer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
            cell.layer.mask = maskLayer
        default:
            let maskLayer = CALayer()
            maskLayer.cornerRadius = 0
            maskLayer.backgroundColor = UIColor.black.cgColor
            maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding / 2)
            
            cell.layer.mask = maskLayer
        }
    }
}

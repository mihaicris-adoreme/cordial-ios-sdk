//
//  ProfileInfoViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 23.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class ProfileInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    
    var profileInfo: [ProfileInfoTableData] = [
        ProfileInfoTableData(title: "Info", data: [
            ProfileInfoData(key: "Device Identifier:", value: UpsertContactsAPI().getDeviceIdentifier()),
            ProfileInfoData(key: "Push Token:", value: UpsertContactsAPI().getPushNotificationToken() ?? "Device token is absent"),
            ProfileInfoData(key: "Notification Status:", value: UpsertContactsAPI().getPushNotificationStatus())
        ])
    ]
    
    let navigationBarBackgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
    let navigationBarTitleColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    let navigationBarXmarkColor = UIColor(red: 135/255, green: 135/255, blue: 135/255, alpha: 1)
    
    let tableViewBackgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)

    let tableViewCellBackgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    let tableViewCellTitleColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributesProfileInfoData = self.getAttributesProfileInfoData()
        if !attributesProfileInfoData.isEmpty {
            self.profileInfo.append(ProfileInfoTableData(title: "Attributes", data: attributesProfileInfoData))
        }
        
        let width = self.view.frame.width
        let height = UINavigationController().navigationBar.frame.size.height
        
        // UINavigationBar
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = self.navigationBarBackgroundColor
    
        let navigationItem = UINavigationItem(title: "\(CordialAPI().getContactPrimaryKey() ?? "Guest")")
        navigationBar.titleTextAttributes = [.foregroundColor: self.navigationBarTitleColor]
        
        if #unavailable(iOS 13.0) {
            let dismissItem = UIBarButtonItem(title: "X", style: .plain, target: nil, action: #selector(self.dismissViewController))
            dismissItem.setTitleTextAttributes([
                .font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.5),
                .foregroundColor: self.navigationBarXmarkColor
            ], for: .normal)
            
            navigationItem.rightBarButtonItem = dismissItem
        }
        
        navigationBar.setItems([navigationItem], animated: false)
        
        // UITableView
        self.tableView = ProfileInfoTableView(frame: self.view.frame)
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.backgroundColor = self.tableViewBackgroundColor
        self.tableView.separatorColor = self.tableViewBackgroundColor
        
        self.tableView.rowHeight = height * 2.2
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(ProfileInfoTableViewCell.self, forCellReuseIdentifier: "cell")
        
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
    
    private func getAttributesProfileInfoData() -> [ProfileInfoData] {
        let upsertContactsAPI = UpsertContactsAPI()
        
        var attributesProfileInfoData: [ProfileInfoData] = []
        
        guard let attributes = upsertContactsAPI.getContactAttributes() else { return attributesProfileInfoData }
        
        let attributesJSON = upsertContactsAPI.getContactAttributesJSON(attributes: attributes)

        guard let attributesJSONData = attributesJSON.data(using: .utf8),
           let attributesJSONDictionary = try? JSONSerialization.jsonObject(with: attributesJSONData, options: []) as? [String: String] else { return attributesProfileInfoData }
        
        attributes.forEach { (key: String, value: AttributeValue) in
            if let stringValue = attributesJSONDictionary[key] {
                switch value {
                case is NumericValue:
                    attributesProfileInfoData.append(ProfileInfoData(key: key, value: stringValue, type: "Numeric"))
                case is BooleanValue:
                    attributesProfileInfoData.append(ProfileInfoData(key: key, value: stringValue, type: "Boolean"))
                case is ArrayValue:
                    attributesProfileInfoData.append(ProfileInfoData(key: key, value: stringValue, type: "Array"))
                case is StringValue:
                    attributesProfileInfoData.append(ProfileInfoData(key: key, value: stringValue, type: "String"))
                case is DateValue:
                    attributesProfileInfoData.append(ProfileInfoData(key: key, value: stringValue, type: "Date"))
                case is GeoValue:
                    attributesProfileInfoData.append(ProfileInfoData(key: key, value: stringValue, type: "Geo"))
                default:
                    attributesProfileInfoData.append(ProfileInfoData(key: key, value: stringValue, type: "JSON"))
                }
            }
        }
        
        return attributesProfileInfoData
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true)
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.profileInfo.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.profileInfo[section].data.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.profileInfo[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProfileInfoTableViewCell
                
        let settings = self.profileInfo[indexPath.section].data[indexPath.row]
        
        cell.type.textColor = self.tableViewCellTitleColor
        if let type = settings.type {
            cell.type.text = type
        }
        
        cell.key.text = "\(settings.key)"
        cell.key.textColor = self.tableViewCellTitleColor
        
        cell.value.text = "\(settings.value)"
        cell.value.textColor = self.tableViewCellTitleColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textAlignment = .center
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
        case self.profileInfo[indexPath.section].data.count - 1:
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


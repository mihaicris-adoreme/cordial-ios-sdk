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
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
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
        
        attributes.forEach { (key: String, value: AttributeValue) in
            switch value {
            case is NumericValue:
                let numericValue = value as! NumericValue
                
                var profileInfoValue = "null"
                if let numericDoubleValue = numericValue.value { profileInfoValue = String(numericDoubleValue) }
                
                attributesProfileInfoData.append(ProfileInfoData(key: key, value: profileInfoValue, type: "Numeric"))
            case is BooleanValue:
                let booleanValue = value as! BooleanValue
                
                var profileInfoValue = "false"
                if booleanValue.value { profileInfoValue = "true" }
                    
                attributesProfileInfoData.append(ProfileInfoData(key: key, value: profileInfoValue, type: "Boolean"))
            case is ArrayValue:
                let arrayValue = value as! ArrayValue
                
                var profileInfoValue = String()
                arrayValue.value.forEach { string in
                    if profileInfoValue.isEmpty {
                        profileInfoValue = string
                    } else {
                        profileInfoValue += ", \(string)"
                    }
                }
                
                attributesProfileInfoData.append(ProfileInfoData(key: key, value: profileInfoValue, type: "Array"))
            case is StringValue:
                let stringValue = value as! StringValue
                
                var profileInfoValue = "null"
                if let stringValueString = stringValue.value { profileInfoValue = stringValueString }
                
                attributesProfileInfoData.append(ProfileInfoData(key: key, value: profileInfoValue, type: "String"))
            case is DateValue:
                let dateValue = value as! DateValue
                
                var profileInfoValue = "null"
                if let dateValueDate = dateValue.value { profileInfoValue = AppDateFormatter().getTimestampFromDate(date: dateValueDate) }
                
                attributesProfileInfoData.append(ProfileInfoData(key: key, value: profileInfoValue, type: "Date"))
            case is GeoValue:
                let geoValue = value as! GeoValue
                
                let profileInfoValue = self.getGeoValueString(geoValue: geoValue)
                
                attributesProfileInfoData.append(ProfileInfoData(key: key, value: profileInfoValue.string, type: "Geo"))
            default:
                break
            }
        }
        
        return attributesProfileInfoData
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true)
    }
    
    private func getGeoValueString(geoValue: GeoValue) -> NSAttributedString {
        let titleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        let valueAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)]
        
        let cityTitle = NSAttributedString(string: "City: ", attributes: titleAttributes)
        let countryTitle = NSAttributedString(string: "Country: ", attributes: titleAttributes)
        let postalCodeTitle = NSAttributedString(string: "Postal Code: ", attributes: titleAttributes)
        let stateTitle = NSAttributedString(string: "State: ", attributes: titleAttributes)
        let streetAddressTitle = NSAttributedString(string: "Street Address: ", attributes: titleAttributes)
        let streetAddress2Title = NSAttributedString(string: "Street Address 2: ", attributes: titleAttributes)
        let timeZoneTitle = NSAttributedString(string: "Time Zone: ", attributes: titleAttributes)
        
        let cityValue = NSAttributedString(string: "\(geoValue.getCity())", attributes: valueAttributes)
        let countryValue = NSAttributedString(string: "\(geoValue.getCountry())", attributes: valueAttributes)
        let postalCodeValue = NSAttributedString(string: "\(geoValue.getPostalCode())", attributes: valueAttributes)
        let stateValue = NSAttributedString(string: "\(geoValue.getState())", attributes: valueAttributes)
        let streetAddressValue = NSAttributedString(string: "\(geoValue.getStreetAddress())", attributes: valueAttributes)
        let streetAddress2Value = NSAttributedString(string: "\(geoValue.getStreetAddress2())", attributes: valueAttributes)
        let timeZoneValue = NSAttributedString(string: "\(geoValue.getTimeZone())", attributes: valueAttributes)
        
        let newLine = NSAttributedString(string: "\n", attributes: titleAttributes)
        
        let geoValueString = NSMutableAttributedString()
        geoValueString.append(cityTitle)
        geoValueString.append(cityValue)
        
        geoValueString.append(newLine)
        
        geoValueString.append(countryTitle)
        geoValueString.append(countryValue)
        
        geoValueString.append(newLine)
        
        geoValueString.append(postalCodeTitle)
        geoValueString.append(postalCodeValue)
        
        geoValueString.append(newLine)
        
        geoValueString.append(stateTitle)
        geoValueString.append(stateValue)
        
        geoValueString.append(newLine)
        
        geoValueString.append(streetAddressTitle)
        geoValueString.append(streetAddressValue)
        
        geoValueString.append(newLine)
        
        geoValueString.append(streetAddress2Title)
        geoValueString.append(streetAddress2Value)
        
        geoValueString.append(newLine)
        
        geoValueString.append(timeZoneTitle)
        geoValueString.append(timeZoneValue)
        
        return geoValueString
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
        } else {
            cell.type.text = String()
        }
        
        cell.key.text = settings.key
        cell.key.textColor = self.tableViewCellTitleColor
        
        cell.value.text = settings.value
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
        
        cell.layoutIfNeeded()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let settings = self.profileInfo[indexPath.section].data[indexPath.row]
        
        guard let type = settings.type else { return 95 }
        
        switch type {
        case "Array":
            return 125
        case "Geo":
            return 200
        default:
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

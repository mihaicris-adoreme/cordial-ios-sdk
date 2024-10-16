//
//  ProfileViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 5/16/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var primaryKeyInfoLabel: UILabel!
    @IBOutlet weak var primaryKeyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let profileCell = "profileTableCell"
    let profileFooterIdentifier = "profileTableFooter"
    
    var profileTableFooterView: ProfileTableFooterView!
    
    let cordialAPI = CordialAPI()
    
    var attributes = [Attribute]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.title = "Profile"
        
        if let primaryKey = self.cordialAPI.getContactPrimaryKey() {
            self.primaryKeyLabel.text = primaryKey
        } else {
            self.primaryKeyInfoLabel.text = "Guest"
        }
        
        self.tableView.register(UINib(nibName: "ProfileTableFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: self.profileFooterIdentifier)
        self.profileTableFooterView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: self.profileFooterIdentifier) as? ProfileTableFooterView
        
        let profileInfoButton = UIBarButtonItem(image: UIImage(named: "profile"), style: .plain, target: self, action: #selector(self.profileInfoButtonAction))
        navigationItem.rightBarButtonItems = [profileInfoButton]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.attributes = AppDataManager.shared.attributes.getAttributesFromCoreData(appDelegate: appDelegate)
            self.tableView.tableFooterView = UIView(frame: .zero)
            self.tableView.reloadData()
        }
    }
    
    @objc func profileInfoButtonAction() {
        self.present(ProfileInfoViewController(), animated: true)
    }
    
    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.tableView.dequeueReusableHeaderFooterView(withIdentifier: self.profileFooterIdentifier)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if !self.attributes.isEmpty {
            return self.profileTableFooterView.frame.size.height
        }
        
        return 0
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.attributes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: profileCell, for: indexPath) as! ProfileTableViewCell

        let attribute = self.attributes[indexPath.row]
        
        let titleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        let valueAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)]
        
        let typeString = attribute.type.rawValue.capitalized
        cell.typeLabel.attributedText = NSAttributedString(string: typeString, attributes: valueAttributes)
        
        let keyString = attribute.key
        cell.keyLabel.attributedText = NSAttributedString(string: keyString, attributes: valueAttributes)
        
        let valueString = Attribute.performArrayToStringSeparatedByComma(attribute.value)
        var value = NSAttributedString(string: valueString, attributes: valueAttributes)
        
        switch attribute.type {
        case AttributeType.date:
            if let date = CordialDateFormatter().getDateFromTimestamp(timestamp: valueString) {
                let dateString = AppDateFormatter().getTimestampFromDate(date: date)
                value = NSAttributedString(string: dateString, attributes: valueAttributes)
            }
        case AttributeType.geo:
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let geoAttribute = AppDataManager.shared.geoAttributes.getGeoAttributeFromCoreDataByKey(appDelegate: appDelegate, key: attribute.key) {
                
                let cityTitle = NSAttributedString(string: "City: ", attributes: titleAttributes)
                let countryTitle = NSAttributedString(string: "Country: ", attributes: titleAttributes)
                let postalCodeTitle = NSAttributedString(string: "Postal Code: ", attributes: titleAttributes)
                let stateTitle = NSAttributedString(string: "State: ", attributes: titleAttributes)
                let streetAddressTitle = NSAttributedString(string: "Street Address: ", attributes: titleAttributes)
                let streetAddress2Title = NSAttributedString(string: "Street Address 2: ", attributes: titleAttributes)
                let timeZoneTitle = NSAttributedString(string: "Time Zone: ", attributes: titleAttributes)
                
                let cityValue = NSAttributedString(string: "\(geoAttribute.city)", attributes: valueAttributes)
                let countryValue = NSAttributedString(string: "\(geoAttribute.country)", attributes: valueAttributes)
                let postalCodeValue = NSAttributedString(string: "\(geoAttribute.postalCode)", attributes: valueAttributes)
                let stateValue = NSAttributedString(string: "\(geoAttribute.state)", attributes: valueAttributes)
                let streetAddressValue = NSAttributedString(string: "\(geoAttribute.streetAddress)", attributes: valueAttributes)
                let streetAddress2Value = NSAttributedString(string: "\(geoAttribute.streetAddress2)", attributes: valueAttributes)
                let timeZoneValue = NSAttributedString(string: "\(geoAttribute.timeZone)", attributes: valueAttributes)
                
                let newLine = NSAttributedString(string: "\n", attributes: titleAttributes)
                
                let geoValue = NSMutableAttributedString()
                geoValue.append(cityTitle)
                geoValue.append(cityValue)
                
                geoValue.append(newLine)
                
                geoValue.append(countryTitle)
                geoValue.append(countryValue)
                
                geoValue.append(newLine)
                
                geoValue.append(postalCodeTitle)
                geoValue.append(postalCodeValue)
                
                geoValue.append(newLine)
                
                geoValue.append(stateTitle)
                geoValue.append(stateValue)
                
                geoValue.append(newLine)
                
                geoValue.append(streetAddressTitle)
                geoValue.append(streetAddressValue)
                
                geoValue.append(newLine)
                
                geoValue.append(streetAddress2Title)
                geoValue.append(streetAddress2Value)
                
                geoValue.append(newLine)
                
                geoValue.append(timeZoneTitle)
                geoValue.append(timeZoneValue)
                
                value = geoValue
            }
        default:
            break
        }
        
        cell.valueLabel.attributedText = value
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete,
           let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            let attribute = self.attributes[indexPath.row]
            
            AppDataManager.shared.attributes.deleteAttributeByKey(appDelegate: appDelegate, key: attribute.key)
            
            switch attribute.type {
            case AttributeType.geo:
                AppDataManager.shared.geoAttributes.deleteGeoAttributeByKey(appDelegate: appDelegate, key: attribute.key)
            default:
                break
            }
            
            
            self.attributes.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }

    }
    
}

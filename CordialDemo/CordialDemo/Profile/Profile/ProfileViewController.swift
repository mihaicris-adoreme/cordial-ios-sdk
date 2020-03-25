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

    @IBOutlet weak var primaryKeyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let profileCell = "profileTableCell"
    let profileFooterCell = "profileTableFooterCell"
    
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
        }
        
        self.tableView.register(UINib(nibName: "ProfileTableFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: profileFooterCell)
        self.profileTableFooterView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: profileFooterCell) as? ProfileTableFooterView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.attributes = AppDataManager.shared.attributes.getAttributesFromCoreData(appDelegate: appDelegate)
            self.tableView.tableFooterView = UIView(frame: .zero)
            self.tableView.reloadData()
        }
    }
    
    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.tableView.dequeueReusableHeaderFooterView(withIdentifier: profileFooterCell)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.attributes.count > 0 {
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
        
        cell.typeLabel.text = attribute.type.rawValue.capitalized
        cell.keyLabel.text = attribute.key
        
        var value = Attribute.performArrayToStringSeparatedByComma(attribute.value)
        
        switch attribute.type {
        case AttributeType.date:
            let date = CordialDateFormatter().getDateFromTimestamp(timestamp: value)!
            value = AppDateFormatter().getTimestampFromDate(date: date)
        case AttributeType.geo:
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let geoAttribute = AppDataManager.shared.geoAttributes.getGeoAttributeFromCoreDataByKey(appDelegate: appDelegate, key: attribute.key) {
                value = "City:\t\t\t\t\(geoAttribute.city)\nCountry:\t\t\t\(geoAttribute.country)\nPostal Code:\t\t\(geoAttribute.postalCode)\nState:\t\t\t\t\(geoAttribute.state)\nStreet Adress:\t\t\(geoAttribute.streetAdress)\nStreet Adress 2:\t\(geoAttribute.streetAdress2)\nTime Zone:\t\t\t\(geoAttribute.timeZone)"
            }
        default:
            break
        }
        
        cell.valueLabel.text = value
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
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

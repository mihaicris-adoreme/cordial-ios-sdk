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
            self.tableView.reloadData()
        }
    }
    
    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.tableView.dequeueReusableHeaderFooterView(withIdentifier: profileFooterCell)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if self.attributes.count > 0 {
            let attributeHeight = self.tableView.frame.size.height / 5
            let attributesHeight = attributeHeight * CGFloat(self.attributes.count)
            let calculatedHeightForFooter = self.tableView.frame.size.height - attributesHeight
            
            if calculatedHeightForFooter > self.profileTableFooterView.frame.size.height {
                return calculatedHeightForFooter
            } else {
                return self.profileTableFooterView.frame.size.height
            }
        }
        
        return 0
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.attributes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: profileCell, for: indexPath)

        let attribute = self.attributes[indexPath.row]
        
        cell.textLabel?.text = attribute.key
        cell.detailTextLabel?.text = attribute.value
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.size.height / 5
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            let attribute = self.attributes[indexPath.row]
            
            AppDataManager.shared.attributes.deleteAttributeByKey(appDelegate: appDelegate, key: attribute.key)
            
            self.attributes.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }

    }
    
}

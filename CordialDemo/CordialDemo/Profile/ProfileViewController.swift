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
    
    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.tableView.dequeueReusableHeaderFooterView(withIdentifier: profileFooterCell)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.profileTableFooterView.frame.size.height
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: profileCell, for: indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.size.height / 5
    }

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == UITableViewCell.EditingStyle.delete, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            AppDataManager.shared.deleteCartItemBySKU(appDelegate: appDelegate, sku: products[indexPath.row].sku)
//
//            products.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
//
//            self.upsertContactCart()
//            self.upsertCartTableFooterView()
//        }
//    }
}

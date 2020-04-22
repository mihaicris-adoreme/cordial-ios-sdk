//
//  CustomEventViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 22.04.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class CustomEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventNameInfoLabel: UILabel!
    
    let customEventCell = "customEventTableCell"
    let customEventFooterIdentifier = "customEventTableFooter"
    
    var properties = [CustomEventProperty]()
    
    var customEventTableFooterView: CustomEventTableFooterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(UINib(nibName: "CustomEventTableFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: self.customEventFooterIdentifier)
        self.customEventTableFooterView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: self.customEventFooterIdentifier) as? CustomEventTableFooterView
        
        self.customEventTableFooterView.сustomEventViewController = self
        
        self.eventNameTextField.setBottomBorder(color: UIColor.lightGray)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.eventNameTextField.resignFirstResponder()
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.reloadData()
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.customEventTableFooterView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.customEventTableFooterView.frame.size.height
    }
    
    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.properties.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.customEventCell, for: indexPath) as! CustomEventTableViewCell

        let property = self.properties[indexPath.row]
        
        cell.keyLabel.text = property.key
        cell.valueLabel.text = property.value
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            self.properties.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            self.tableView.reloadData()
        }
    }
    
}

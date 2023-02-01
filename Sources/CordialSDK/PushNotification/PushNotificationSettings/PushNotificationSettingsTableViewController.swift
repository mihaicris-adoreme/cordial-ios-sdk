//
//  PushNotificationSettingsTableViewController.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 01.02.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class PushNotificationSettingsTableViewController: UITableViewController {

    private let sections = ["PUSH NOTIFICATIONS FILTER"]
    private let rows = [CordialApiConfiguration.shared.pushNotificationSettings]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(self.dismissViewController))
        
        self.tableView.register(PushNotificationSettingsTableViewCell.self, forCellReuseIdentifier: "cell")
    }

    @objc func dismissViewController() {
        self.dismiss(animated: true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows[section].count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PushNotificationSettingsTableViewCell

        cell.selectionStyle = .none
        
        cell.title.text = "\(rows[indexPath.section][indexPath.row])"

        return cell
    }

}

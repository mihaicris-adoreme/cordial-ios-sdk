//
//  LogsTableViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 03.01.2024.
//  Copyright © 2024 cordial.io. All rights reserved.
//

import UIKit

class LogsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let reuseIdentifier = "logsTableCell"
    
    var logs: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Logs"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.prepareLogsTextView()
    }
    
    @IBAction func logsRefreshAction(_ sender: UIBarButtonItem) {
        self.prepareLogsTextView()
    }
    
    @IBAction func logsRemoveAction(_ sender: UIBarButtonItem) {
        FileLogger.shared.remove()
        
        self.prepareLogsTextView()
    }
    
    func prepareLogsTextView() {
        self.logs = []
        
        if #available(iOS 13.4, *) {
            let logs = FileLogger.shared.read()
            
            for log in logs.components(separatedBy: "\n\n") {
                if !log.isEmpty {
                    self.logs.append(log)
                }
            }
        }
        
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! LogsTableViewCell
                
        let log = self.logs[indexPath.row]
        
        cell.logsTextView.text = "\(log)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO
    }
}

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
    var selectedIndex: IndexPath = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Logs"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressGesture(sender:)))
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.prepareLogsTextView()
    }
    
    @IBAction func logsRefreshAction(_ sender: UIBarButtonItem) {
        self.prepareLogsTextView()
    }
    
    @IBAction func logsRemoveAction(_ sender: UIBarButtonItem) {
        if !self.selectedIndex.isEmpty {
            let log = self.logs[self.selectedIndex.row]

            if #available(iOS 13.4, *) {
                FileLogger.shared.removeTo(log: log)
            } else {
                FileLogger.shared.deleteAll()
            }
        } else {
            FileLogger.shared.deleteAll()
        }
        
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
        self.selectedIndex = []
    }
    
    @objc func longPressGesture(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: self.tableView)
            
            if let indexPath = self.tableView.indexPathForRow(at: touchPoint) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                UIPasteboard.general.string = self.logs[indexPath.row]
                
                if #available(iOS 13.0, *) {
                    let size = self.view.frame.width / 5
                    let frame = CGRect(x: 0, y: 0, width: size, height: size)

                    let config = UIImage.SymbolConfiguration(pointSize: 1, weight: .semibold, scale: .large)
                    let image = UIImage(systemName: "checkmark", withConfiguration: config)

                    let imageView = UIImageView(frame: frame)
                    imageView.image = image
                    imageView.center = self.view.center

                    self.view.addSubview(imageView)

                    imageView.popIn()
                    imageView.popOut()
                }
            }
        }
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
        self.selectedIndex = indexPath
    }
}

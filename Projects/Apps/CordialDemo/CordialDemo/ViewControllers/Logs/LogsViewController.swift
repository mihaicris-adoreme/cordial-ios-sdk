//
//  LogsViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 08.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class LogsViewController: UIViewController {

    @IBOutlet weak var logsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Logs"
        
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
        if #available(iOS 13.4, *) {
            self.logsTextView.text = FileLogger.shared.read()
        }
    }
}

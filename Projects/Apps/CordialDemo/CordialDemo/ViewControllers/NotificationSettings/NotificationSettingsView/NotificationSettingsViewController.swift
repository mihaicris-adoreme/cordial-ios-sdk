//
//  NotificationSettingsViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 13.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class NotificationSettingsViewController: UIViewController {
    
    var titleTextAttributes: [NSAttributedString.Key : Any]?
    var barTintColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "App"
        
        self.view.backgroundColor = UIColor.black
        
        let width = self.view.frame.size.width / 2
        let height = self.view.frame.size.height / 2
        
        let x = self.view.frame.size.width / 2 - width / 2
        let y = self.view.frame.size.height / 2 - height / 2
        
        let notificationSettingsLabel = NotificationSettingsLabel(frame: CGRect(x: x, y: y, width: width, height: height), fontSize: 17)
        notificationSettingsLabel.text = "Notification Settings"
        
        self.view.addSubview(notificationSettingsLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.titleTextAttributes = self.navigationController?.navigationBar.titleTextAttributes
        self.barTintColor = self.navigationController?.navigationBar.barTintColor
        
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.titleTextAttributes = self.titleTextAttributes
        self.navigationController?.navigationBar.barTintColor = self.barTintColor
    }
}

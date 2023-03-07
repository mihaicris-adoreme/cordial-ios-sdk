//
//  PushNotificationSettingsTableViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 02.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

@available(iOS 14.0, *)
class PushNotificationSettingsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIColorPickerViewControllerDelegate {
    
    @IBOutlet weak var tableView: PushNotificationSettingsTableView!
    
    let picker = UIColorPickerViewController()
    
    private var sections: [PushNotificationSettingsTableData] = [
        PushNotificationSettingsTableData(title: "NAVIGATION BAR", data: [
            PushNotificationSettingsData(key: "navigation_bar_background_color", title: "Background color", color: PushNotificationSettingsHandler.shared.navigationBarBackgroundColor),
            PushNotificationSettingsData(key: "navigation_bar_title_color", title: "Title color", color: PushNotificationSettingsHandler.shared.navigationBarTitleColor),
            PushNotificationSettingsData(key: "navigation_bar_xmark_color", title: "Xmark color", color: PushNotificationSettingsHandler.shared.navigationBarXmarkColor)
        ]),
        PushNotificationSettingsTableData(title: "TABLE VIEW", data: [
            PushNotificationSettingsData(key: "table_view_background_color", title: "Background color", color: PushNotificationSettingsHandler.shared.tableViewBackgroundColor),
            PushNotificationSettingsData(key: "table_view_section_title_color", title: "Section title color", color: PushNotificationSettingsHandler.shared.tableViewSectionTitleColor),
            PushNotificationSettingsData(key: "table_view_cell_background_color", title: "Cell background color", color: PushNotificationSettingsHandler.shared.tableViewCellBackgroundColor),
            PushNotificationSettingsData(key: "table_view_cell_title_color", title: "Cell title color", color: PushNotificationSettingsHandler.shared.tableViewCellTitleColor),
            PushNotificationSettingsData(key: "table_view_cell_switch_on_color", title: "Cell switch on color", color: PushNotificationSettingsHandler.shared.tableViewCellSwitchOnColor),
            PushNotificationSettingsData(key: "table_view_cell_switch_thumb_color", title: "Cell switch thumb color", color: PushNotificationSettingsHandler.shared.tableViewCellSwitchThumbColor)
        ])
    ]
    
    var key = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
        
        let settingsButton = UIBarButtonItem(image: UIImage(named: "settings")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.openPushNotificationSettings))
        navigationItem.rightBarButtonItems = [settingsButton]
        
        // UIColorPickerView
        self.picker.delegate = self
        
        // UITableView
        self.tableView.showsVerticalScrollIndicator = false
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(PushNotificationSettingsTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configuration
        let wrapTableView = UIView(frame: self.view.frame)
  
        if let tableView = self.tableView {
            wrapTableView.addSubview(tableView)
            
            let views = ["tableView": tableView]

            wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views))
            wrapTableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: views))
            
            self.view.addSubview(wrapTableView)
        } else {
            self.dismiss(animated: false)
        }
    }
    
    @objc func openPushNotificationSettings() {
        PushNotificationSettingsHandler.shared.openPushNotificationSettings()
    }
    
    @available(iOS 14.0, *)
    @objc func colorImageTapped(_ tapGestureRecognizer: PushNotificationSettingsTapGestureRecognizer) {
        let section = tapGestureRecognizer.indexPath.section
        let row = tapGestureRecognizer.indexPath.row
        
        let settings = self.sections[section].data[row]
        
        self.key = settings.key
        
        DispatchQueue.main.async {
            self.present(self.picker, animated: true)
        }
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].data.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PushNotificationSettingsTableViewCell
                
        let settings = self.sections[indexPath.section].data[indexPath.row]
        
        cell.title.text = "\(settings.title)"
        cell.colorImage.image = settings.color.image(CGSize(width: 50, height: 30))
        cell.colorImage.roundImage(borderWidth: 1, borderColor: UIColor.black)
        
        // Check version is necessary - minimum target iOS 12
        if #available(iOS 14.0, *) {
            let tapGestureRecognizer = PushNotificationSettingsTapGestureRecognizer(indexPath: indexPath, target: self, action: #selector(self.colorImageTapped(_:)))
            cell.colorImage.isUserInteractionEnabled = true
            cell.colorImage.addGestureRecognizer(tapGestureRecognizer)
        } 
        
        return cell
    }
  
    // MARK: - UIColorPickerViewControllerDelegate
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        switch self.key {
        case "navigation_bar_background_color":
            PushNotificationSettingsHandler.shared.navigationBarBackgroundColor = viewController.selectedColor
        case "navigation_bar_title_color":
            PushNotificationSettingsHandler.shared.navigationBarTitleColor = viewController.selectedColor
        case "navigation_bar_xmark_color":
            PushNotificationSettingsHandler.shared.navigationBarXmarkColor = viewController.selectedColor
        case "table_view_background_color":
            PushNotificationSettingsHandler.shared.tableViewBackgroundColor = viewController.selectedColor
        case "table_view_section_title_color":
            PushNotificationSettingsHandler.shared.tableViewSectionTitleColor = viewController.selectedColor
        case "table_view_cell_background_color":
            PushNotificationSettingsHandler.shared.tableViewCellBackgroundColor = viewController.selectedColor
        case "table_view_cell_title_color":
            PushNotificationSettingsHandler.shared.tableViewCellTitleColor = viewController.selectedColor
        case "table_view_cell_switch_on_color":
            PushNotificationSettingsHandler.shared.tableViewCellSwitchOnColor = viewController.selectedColor
        case "table_view_cell_switch_thumb_color":
            PushNotificationSettingsHandler.shared.tableViewCellSwitchThumbColor = viewController.selectedColor
        default:
            break
        }
        
        self.sections = [
            PushNotificationSettingsTableData(title: "NAVIGATION BAR", data: [
                PushNotificationSettingsData(key: "navigation_bar_background_color", title: "Background color", color: PushNotificationSettingsHandler.shared.navigationBarBackgroundColor),
                PushNotificationSettingsData(key: "navigation_bar_title_color", title: "Title color", color: PushNotificationSettingsHandler.shared.navigationBarTitleColor),
                PushNotificationSettingsData(key: "navigation_bar_xmark_color", title: "Xmark color", color: PushNotificationSettingsHandler.shared.navigationBarXmarkColor)
            ]),
            PushNotificationSettingsTableData(title: "TABLE VIEW", data: [
                PushNotificationSettingsData(key: "table_view_background_color", title: "Background color", color: PushNotificationSettingsHandler.shared.tableViewBackgroundColor),
                PushNotificationSettingsData(key: "table_view_section_title_color", title: "Section title color", color: PushNotificationSettingsHandler.shared.tableViewSectionTitleColor),
                PushNotificationSettingsData(key: "table_view_cell_background_color", title: "Cell background color", color: PushNotificationSettingsHandler.shared.tableViewCellBackgroundColor),
                PushNotificationSettingsData(key: "table_view_cell_title_color", title: "Cell title color", color: PushNotificationSettingsHandler.shared.tableViewCellTitleColor),
                PushNotificationSettingsData(key: "table_view_cell_switch_on_color", title: "Cell switch on color", color: PushNotificationSettingsHandler.shared.tableViewCellSwitchOnColor),
                PushNotificationSettingsData(key: "table_view_cell_switch_thumb_color", title: "Cell switch thumb color", color: PushNotificationSettingsHandler.shared.tableViewCellSwitchThumbColor)
            ])
        ]
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

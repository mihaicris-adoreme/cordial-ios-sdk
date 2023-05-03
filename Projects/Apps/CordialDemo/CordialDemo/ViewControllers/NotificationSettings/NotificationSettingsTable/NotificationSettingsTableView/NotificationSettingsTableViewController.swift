//
//  NotificationSettingsTableViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 02.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

@available(iOS 14.0, *)
class NotificationSettingsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIColorPickerViewControllerDelegate {
    
    @IBOutlet weak var tableView: NotificationSettingsTableView!
    
    let picker = UIColorPickerViewController()
    
    private var sections: [NotificationSettingsTableData] = [
        NotificationSettingsTableData(title: "NAVIGATION BAR", data: [
            NotificationSettingsData(key: "navigation_bar_background_color", title: "Background color", color: PushNotificationCategoriesHandler.shared.navigationBarBackgroundColor),
            NotificationSettingsData(key: "navigation_bar_title_color", title: "Title color", color: PushNotificationCategoriesHandler.shared.navigationBarTitleColor),
            NotificationSettingsData(key: "navigation_bar_xmark_color", title: "Xmark color", color: PushNotificationCategoriesHandler.shared.navigationBarXmarkColor)
        ]),
        NotificationSettingsTableData(title: "TABLE VIEW", data: [
            NotificationSettingsData(key: "table_view_background_color", title: "Background color", color: PushNotificationCategoriesHandler.shared.tableViewBackgroundColor),
            NotificationSettingsData(key: "table_view_section_title_color", title: "Section title color", color: PushNotificationCategoriesHandler.shared.tableViewSectionTitleColor),
            NotificationSettingsData(key: "table_view_cell_background_color", title: "Cell background color", color: PushNotificationCategoriesHandler.shared.tableViewCellBackgroundColor),
            NotificationSettingsData(key: "table_view_cell_title_color", title: "Cell title color", color: PushNotificationCategoriesHandler.shared.tableViewCellTitleColor),
            NotificationSettingsData(key: "table_view_cell_switch_on_color", title: "Cell switch on color", color: PushNotificationCategoriesHandler.shared.tableViewCellSwitchOnColor),
            NotificationSettingsData(key: "table_view_cell_switch_thumb_color", title: "Cell switch thumb color", color: PushNotificationCategoriesHandler.shared.tableViewCellSwitchThumbColor)
        ])
    ]
    
    var key = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
        
        let educationalButton = UIBarButtonItem(image: UIImage(named: "books")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.openEducationalPushNotificationSettings))
        let settingsButton = UIBarButtonItem(image: UIImage(named: "settings")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.openPushNotificationSettings))
        navigationItem.rightBarButtonItems = [settingsButton, educationalButton]
        
        // UIColorPickerView
        self.picker.delegate = self
        self.picker.modalPresentationStyle = .fullScreen
        NotificationSettingsTableViewColorPicker.setup(self.picker)
        
        // UITableView
        self.tableView.showsVerticalScrollIndicator = false
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(NotificationSettingsTableViewCell.self, forCellReuseIdentifier: "cell")
        
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
    
    @objc func openEducationalPushNotificationSettings() {
        PushNotificationCategoriesHandler.shared.openEducationalPushNotificationCategories(options: [])
    }
    
    @objc func openPushNotificationSettings() {
        PushNotificationCategoriesHandler.shared.openPushNotificationCategories()
    }
    
    @available(iOS 14.0, *)
    @objc func colorImageTapped(_ tapGestureRecognizer: NotificationSettingsTableViewTapGestureRecognizer) {
        let section = tapGestureRecognizer.indexPath.section
        let row = tapGestureRecognizer.indexPath.row
        
        let settings = self.sections[section].data[row]
        
        self.key = settings.key
        
        DispatchQueue.main.async {
            self.picker.selectedColor = settings.color
            
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotificationSettingsTableViewCell
                
        let settings = self.sections[indexPath.section].data[indexPath.row]
        
        cell.title.text = "\(settings.title)"
        cell.colorImage.image = settings.color.image(CGSize(width: 50, height: 30))
        cell.colorImage.roundImage(borderWidth: 1, borderColor: UIColor.black)
        
        NotificationSettingsTableViewCellTapGestureRecognizer.setup(cell: cell, indexPath: indexPath, sender: self)
        
        return cell
    }
  
    // MARK: - UIColorPickerViewControllerDelegate
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        switch self.key {
        case "navigation_bar_background_color":
            PushNotificationCategoriesHandler.shared.navigationBarBackgroundColor = viewController.selectedColor
        case "navigation_bar_title_color":
            PushNotificationCategoriesHandler.shared.navigationBarTitleColor = viewController.selectedColor
        case "navigation_bar_xmark_color":
            PushNotificationCategoriesHandler.shared.navigationBarXmarkColor = viewController.selectedColor
        case "table_view_background_color":
            PushNotificationCategoriesHandler.shared.tableViewBackgroundColor = viewController.selectedColor
        case "table_view_section_title_color":
            PushNotificationCategoriesHandler.shared.tableViewSectionTitleColor = viewController.selectedColor
        case "table_view_cell_background_color":
            PushNotificationCategoriesHandler.shared.tableViewCellBackgroundColor = viewController.selectedColor
        case "table_view_cell_title_color":
            PushNotificationCategoriesHandler.shared.tableViewCellTitleColor = viewController.selectedColor
        case "table_view_cell_switch_on_color":
            PushNotificationCategoriesHandler.shared.tableViewCellSwitchOnColor = viewController.selectedColor
        case "table_view_cell_switch_thumb_color":
            PushNotificationCategoriesHandler.shared.tableViewCellSwitchThumbColor = viewController.selectedColor
        default:
            break
        }
        
        self.sections = [
            NotificationSettingsTableData(title: "NAVIGATION BAR", data: [
                NotificationSettingsData(key: "navigation_bar_background_color", title: "Background color", color: PushNotificationCategoriesHandler.shared.navigationBarBackgroundColor),
                NotificationSettingsData(key: "navigation_bar_title_color", title: "Title color", color: PushNotificationCategoriesHandler.shared.navigationBarTitleColor),
                NotificationSettingsData(key: "navigation_bar_xmark_color", title: "Xmark color", color: PushNotificationCategoriesHandler.shared.navigationBarXmarkColor)
            ]),
            NotificationSettingsTableData(title: "TABLE VIEW", data: [
                NotificationSettingsData(key: "table_view_background_color", title: "Background color", color: PushNotificationCategoriesHandler.shared.tableViewBackgroundColor),
                NotificationSettingsData(key: "table_view_section_title_color", title: "Section title color", color: PushNotificationCategoriesHandler.shared.tableViewSectionTitleColor),
                NotificationSettingsData(key: "table_view_cell_background_color", title: "Cell background color", color: PushNotificationCategoriesHandler.shared.tableViewCellBackgroundColor),
                NotificationSettingsData(key: "table_view_cell_title_color", title: "Cell title color", color: PushNotificationCategoriesHandler.shared.tableViewCellTitleColor),
                NotificationSettingsData(key: "table_view_cell_switch_on_color", title: "Cell switch on color", color: PushNotificationCategoriesHandler.shared.tableViewCellSwitchOnColor),
                NotificationSettingsData(key: "table_view_cell_switch_thumb_color", title: "Cell switch thumb color", color: PushNotificationCategoriesHandler.shared.tableViewCellSwitchThumbColor)
            ])
        ]
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

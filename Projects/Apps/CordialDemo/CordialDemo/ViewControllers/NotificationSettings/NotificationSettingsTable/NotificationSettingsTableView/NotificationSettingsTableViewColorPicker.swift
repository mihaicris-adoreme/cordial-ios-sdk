//
//  NotificationSettingsTableViewColorPicker.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 27.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class NotificationSettingsTableViewColorPicker {
    
    static func setup(_ picker: UIViewController) {
        if #available(iOS 14.0, *) {
            picker.view.backgroundColor = UIColor.white
        }
    }
}

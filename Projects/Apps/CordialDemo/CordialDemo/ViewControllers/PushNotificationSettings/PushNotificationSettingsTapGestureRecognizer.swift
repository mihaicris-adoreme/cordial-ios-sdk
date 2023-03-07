//
//  PushNotificationSettingsTapGestureRecognizer.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 07.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
class PushNotificationSettingsTapGestureRecognizer: UITapGestureRecognizer {
    
    var indexPath: IndexPath = []
    
    convenience init(indexPath: IndexPath, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        
        self.indexPath = indexPath
    }
}

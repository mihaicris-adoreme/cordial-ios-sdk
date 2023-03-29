//
//  PushNotificationCategoriesTableView.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 03.02.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class PushNotificationCategoriesTableView: UITableView {

    init(frame: CGRect) {
        super.init(frame: frame, style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

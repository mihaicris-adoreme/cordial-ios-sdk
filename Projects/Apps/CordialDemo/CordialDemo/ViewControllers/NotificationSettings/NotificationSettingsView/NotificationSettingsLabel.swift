//
//  NotificationSettingsLabel.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 13.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class NotificationSettingsLabel: UILabel {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.initializeLabel()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initializeLabel()
    }

    func initializeLabel() {
        self.textAlignment = .left
        self.font = UIFont(name: "Halvetica", size: 17)
        self.textColor = UIColor.white
    }
}

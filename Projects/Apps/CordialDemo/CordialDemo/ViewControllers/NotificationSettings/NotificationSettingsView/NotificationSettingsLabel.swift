//
//  NotificationSettingsLabel.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 13.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class NotificationSettingsLabel: UILabel {
    
    init(frame: CGRect, fontSize: CGFloat) {
        super.init(frame: frame)
        
        self.initialize(fontSize: fontSize)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func initialize(fontSize: CGFloat) {
        self.font = UIFont(name: "Halvetica", size: fontSize)
        self.textColor = UIColor.white
        self.textAlignment = .center
    }
}

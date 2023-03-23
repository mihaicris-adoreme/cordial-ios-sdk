//
//  PushNotificationSettingsViewLabel.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 23.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class PushNotificationSettingsViewLabel: UILabel {

    init(frame: CGRect, fontSize: CGFloat) {
        super.init(frame: frame)
        
        self.initialize(fontSize: fontSize)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func initialize(fontSize: CGFloat) {
        self.textAlignment = .center
        self.font = UIFont(name: "Halvetica", size: fontSize)
    }
}

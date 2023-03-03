//
//  PushNotificationSettingsTableViewCell.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 01.02.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class PushNotificationSettingsTableViewCell: UITableViewCell {
    
    let switcher = UISwitch()
    let title = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.switcher.translatesAutoresizingMaskIntoConstraints = false
        self.title.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(self.switcher)
        self.contentView.addSubview(self.title)

        let views = ["switcher": self.switcher, "title": self.title]

        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[title]-|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[switcher]-|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[title]-[switcher]-|", options: [], metrics: nil, views: views))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

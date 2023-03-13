//
//  NotificationSettingsTableViewCell.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 06.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class NotificationSettingsTableViewCell: UITableViewCell {
    
    let title = UILabel()
    var colorImage = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.title.translatesAutoresizingMaskIntoConstraints = false
        self.colorImage.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(self.title)
        self.contentView.addSubview(self.colorImage)

        let views = ["title": self.title, "colorImage": self.colorImage]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[title]-|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[colorImage]-|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[title]-[colorImage]-|", options: [], metrics: nil, views: views))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

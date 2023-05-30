//
//  ProfileInfoTableViewCell.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 23.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class ProfileInfoTableViewCell: UITableViewCell {

    let type = UILabel()
    let key = UILabel()
    let value = UITextView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.type.translatesAutoresizingMaskIntoConstraints = false
        self.key.translatesAutoresizingMaskIntoConstraints = false
        self.value.translatesAutoresizingMaskIntoConstraints = false
        
        let font = UIFont.systemFont(ofSize: 16, weight: .light)
        let mediumFont = UIFont.systemFont(ofSize: 15, weight: .medium)
        let lightFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        self.type.font = font
        self.type.textAlignment = .center
        self.type.numberOfLines = 0
        
        self.key.font = mediumFont
        self.key.textAlignment = .center
        self.key.numberOfLines = 0
        
        self.value.font = lightFont
        self.value.textAlignment = .center
        self.value.isEditable = false
        
        self.contentView.addSubview(self.type)
        self.contentView.addSubview(self.key)
        self.contentView.addSubview(self.value)

        let views = ["type": self.type, "key": self.key, "value": self.value]

        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[type]-[key]-[value]-|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[type]-|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[key]-|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[value]-|", options: [], metrics: nil, views: views))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

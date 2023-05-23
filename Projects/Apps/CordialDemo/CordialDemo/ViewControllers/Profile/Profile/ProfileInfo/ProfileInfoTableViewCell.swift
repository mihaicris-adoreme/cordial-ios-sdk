//
//  ProfileInfoTableViewCell.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 23.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class ProfileInfoTableViewCell: UITableViewCell {

    let key = UILabel()
    let value = UITextView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.key.translatesAutoresizingMaskIntoConstraints = false
        self.value.translatesAutoresizingMaskIntoConstraints = false
        
        self.key.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        self.key.textAlignment = .center
        self.key.numberOfLines = 0
        
        self.value.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        self.value.textAlignment = .center
        self.value.isEditable = false
        
        self.contentView.addSubview(self.key)
        self.contentView.addSubview(self.value)

        let views = ["key": self.key, "value": self.value]

        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[key]-[value]-|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[key]-|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[value]-|", options: [], metrics: nil, views: views))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

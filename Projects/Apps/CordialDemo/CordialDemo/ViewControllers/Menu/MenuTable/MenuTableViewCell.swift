//
//  MenuTableViewCell.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 02.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    let title = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .default
        
        self.title.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(self.title)

        let views = ["title": self.title]

        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[title]-|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[title]-|", options: [], metrics: nil, views: views))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

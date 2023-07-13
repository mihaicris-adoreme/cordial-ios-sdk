//
//  ProfileInfoTableView.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 23.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class ProfileInfoTableView: UITableView {

    init(frame: CGRect) {
        super.init(frame: frame, style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

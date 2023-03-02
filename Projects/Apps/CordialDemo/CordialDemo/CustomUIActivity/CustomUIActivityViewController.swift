//
//  CustomUIActivityViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 02.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class CustomUIActivityViewController: UIViewController {
    
    private let activityController: UIActivityViewController

    init(activities: [UIActivity]) {
        self.activityController = UIActivityViewController(activityItems: [], applicationActivities: activities)
        
        super.init(nibName: nil, bundle: nil)
    
        self.modalPresentationStyle = .formSheet
    }
    
    required init?(coder: NSCoder) {
        fatalError("CustomUIActivityViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.addChild(self.activityController)
        self.view.addSubview(self.activityController.view)

        self.activityController.view.translatesAutoresizingMaskIntoConstraints = false
    
        NSLayoutConstraint.activate([
            self.activityController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.activityController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.activityController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.activityController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }

}

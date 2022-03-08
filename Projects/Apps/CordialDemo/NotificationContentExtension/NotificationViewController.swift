//
//  NotificationViewController.swift
//  NotificationContentExtension
//
//  Created by Yan Malinovsky on 07.03.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    // MARK: - Subvies
    
    private var carouselView: CarouselView?
    
    // MARK: - Properties
    
    private var carouselData = [CarouselView.CarouselData]()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
        
        self.carouselView = CarouselView(pages: 3)
        self.carouselData.append(.init(image: UIImage(named: "Image_1")))
        self.carouselData.append(.init(image: UIImage(named: "Image_2")))
        self.carouselData.append(.init(image: UIImage(named: "Image_3")))
        
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.carouselView?.configureView(with: carouselData)
    }
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        let size = view.bounds.size
        self.preferredContentSize = CGSize(width: size.width, height: size.width)
    }
    
    func didReceive(_ notification: UNNotification) {
//        self.label?.text = notification.request.content.body
    }

    // MARK: - Setups

    private func setupUI() {
        guard let carouselView = self.carouselView else { return }
        
        self.view.addSubview(carouselView)
        carouselView.translatesAutoresizingMaskIntoConstraints = false
        carouselView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        carouselView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        carouselView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        carouselView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

}

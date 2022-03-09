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

    private var carouselView: CarouselView?
    
    private var carouselData = [CarouselView.CarouselData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.view.backgroundColor = .clear
        
        let size = view.bounds.size
        self.preferredContentSize = CGSize(width: size.width, height: size.width)
    }
    
    func didReceive(_ notification: UNNotification) {
//        self.label?.text = notification.request.content.body
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        let categoryIdentifier = "myNotificationCategory"
        
        switch response.actionIdentifier {
        case "\(categoryIdentifier).next":
            self.scrollNextItem()
            completion(.doNotDismiss)
        case "\(categoryIdentifier).previous":
            self.scrollPreviousItem()
            completion(.doNotDismiss)
        default:
            completion(.dismissAndForwardAction)
        }
    }
    
    private func scrollNextItem() {
        var row = self.carouselView?.getCurrentPage() ?? 0
        (row < self.carouselData.count - 1) ? (row += 1) : (row = 0)
        
        self.carouselView?.collectionView.scrollToItem(at: IndexPath(row: row, section: 0), at: .right, animated: true)
    }
    
    private func scrollPreviousItem() {
        var row = self.carouselView?.getCurrentPage() ?? 0
        (row > 0) ? (row -= 1) : (row = self.carouselData.count - 1)
        
        self.carouselView?.collectionView.scrollToItem(at: IndexPath(row: row, section: 0), at: .left, animated: true)
    }

    // MARK: - Setups

    private func setupUI() {
        guard let carouselView = self.carouselView else { return }
        
        self.view.addSubview(carouselView)
        
        carouselView.translatesAutoresizingMaskIntoConstraints = false
        carouselView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        carouselView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        carouselView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        carouselView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
    }

}

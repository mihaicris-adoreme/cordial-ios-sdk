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
import os.log

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    private var carouselView: CarouselView?
    private var carouselData = [CarouselView.CarouselData]()
    private var carousels = [Carousel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: .didReceiveCarouselNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(didReceiveCarouselNotification(notification:)), name: .didReceiveCarouselNotification, object: nil)
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
        let userInfo = notification.request.content.userInfo
        carousels = CarouselNotificationParser.getCarousels(userInfo: userInfo)
        
        NotificationCenter.default.post(name: .didReceiveCarouselNotification, object: carousels)
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
    
    @objc private func didReceiveCarouselNotification(notification: NSNotification) {
        if let carousels = notification.object as? [Carousel] {
            self.carouselView = CarouselView(pages: carousels.count)
            
            carousels.forEach { carousel in
                URLSession.shared.dataTask(with: carousel.imageURL) { data, response, error in
                    if let error = error {
                        os_log("%{public}@", error.localizedDescription)
                        return
                    }
    
                    if let responseData = data {
                        DispatchQueue.main.async {
                            self.carouselData.append(.init(image: UIImage(data: responseData)))
                            
                            self.carouselView?.configureView(with: self.carouselData)
                            
                            self.setupUI()
                        }
                    } else {
                        os_log("Image is absent by the URL")
                    }
                }.resume()
            }
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

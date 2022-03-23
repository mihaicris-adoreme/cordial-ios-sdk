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

    private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    
    private let carouselView = CarouselView()
    private var carouselData = [CarouselView.CarouselData]()
    
    private var isCarouselReady = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: .didReceiveCarouselNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(didReceiveCarouselNotification(notification:)), name: .didReceiveCarouselNotification, object: nil)
        
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.carouselView.configureView(with: self.carouselData)
    }
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = .clear
        
        let size = view.bounds.size
        self.preferredContentSize = CGSize(width: size.width, height: size.width)
    }
        
    func didReceive(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        let carousels = CarouselNotificationParser.getCarousels(userInfo: userInfo)
        
        NotificationCenter.default.post(name: .didReceiveCarouselNotification, object: carousels)
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        let categoryIdentifier = "myNotificationCategory"
        
        if self.isCarouselReady {
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
    }
    
    @objc private func didReceiveCarouselNotification(notification: NSNotification) {
        if let carousels = notification.object as? [Carousel],
            carousels.count > 1 {
            
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }

            carousels.forEach { carousel in
                URLSession.shared.dataTask(with: carousel.imageURL) { data, response, error in
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                    
                    if let error = error {
                        os_log("%{public}@", error.localizedDescription)
                        return
                    }
    
                    if let responseData = data {
                        DispatchQueue.main.async {
                            self.carouselData.append(.init(image: UIImage(data: responseData)))
                            self.carouselView.configureView(with: self.carouselData)
                            
                            self.isCarouselReady = true
                        }
                    } else {
                        os_log("Image is absent by the URL")
                    }
                }.resume()
            }
        }
    }
    
    private func scrollNextItem() {
        var row = self.carouselView.getCurrentPage()
        (row < self.carouselData.count - 1) ? (row += 1) : (row = 0)
        
        self.carouselView.collectionView.scrollToItem(at: IndexPath(row: row, section: 0), at: .right, animated: true)
    }
    
    private func scrollPreviousItem() {
        var row = self.carouselView.getCurrentPage()
        (row > 0) ? (row -= 1) : (row = self.carouselData.count - 1)
        
        self.carouselView.collectionView.scrollToItem(at: IndexPath(row: row, section: 0), at: .left, animated: true)
    }

    private func setupUI() {
        self.view.addSubview(self.activityIndicator)
        
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        self.view.addSubview(self.carouselView)
        
        self.carouselView.translatesAutoresizingMaskIntoConstraints = false
        self.carouselView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.carouselView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.carouselView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.carouselView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
    }

}

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
        
        notificationCenter.removeObserver(self, name: .didReceiveCarouselsNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(didReceiveCarouselsNotification(notification:)), name: .didReceiveCarouselsNotification, object: nil)
        
        self.setupUI()
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
        
        NotificationCenter.default.post(name: .didReceiveCarouselsNotification, object: carousels)
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
    
    @objc private func didReceiveCarouselsNotification(notification: NSNotification) {
        if let carousels = notification.object as? [Carousel],
           !carousels.isEmpty {
            
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
                
                var carouselDeepLinks = [String]()
                
                for (index, carousel) in carousels.enumerated() {
                    URLSession.shared.dataTask(with: carousel.imageURL) { data, response, error in
                        DispatchQueue.main.async {
                            if let error = error {
                                self.unlockActionButtonsIfNeeded()
                                os_log("%{public}@", error.localizedDescription)
                                return
                            }
            
                            if let responseData = data {
                                if let image = UIImage(data: responseData) {
                                    let carouselData = CarouselView.CarouselData(image: image)
                                    self.carouselData.append(carouselData)
                                    
                                    carouselDeepLinks.append(carousel.deepLink.absoluteString)
                                    CarouselGroupUserDefaults.set(carouselDeepLinks, forKey: CarouselNotificationExtension.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_DEEP_LINKS)
                                } else {
                                    self.unlockActionButtonsIfNeeded()
                                    os_log("Image data by URL is not a image")
                                }
                                
                                if index == carousels.count - 1 {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        self.carouselView.configureView(with: self.carouselData)
                                        
                                        self.carouselView.collectionView.performBatchUpdates(nil, completion: { _ in
                                            self.unlockActionButtonsIfNeeded()
                                        })
                                    }
                                }
                            } else {
                                self.unlockActionButtonsIfNeeded()
                                os_log("Image by the URL is absent")
                            }
                        }
                    }.resume()
                }
            }
        }
    }
    
    private func unlockActionButtonsIfNeeded() {
        self.activityIndicator.stopAnimating()
        
        if self.carouselData.count > 1 {
            self.isCarouselReady = true
        }
    }
    
    private func scrollNextItem() {
        var row = self.carouselView.getCurrentPage()
        
        (row < self.carouselData.count - 1) ? (row += 1) : (row = 0)
        
        CarouselGroupUserDefaults.set(row, forKey: CarouselNotificationExtension.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_DEEP_LINK_ID)
        
        self.carouselView.collectionView.scrollToItem(at: IndexPath(row: row, section: 0), at: .right, animated: true)
    }
    
    private func scrollPreviousItem() {
        var row = self.carouselView.getCurrentPage()
        
        (row > 0) ? (row -= 1) : (row = self.carouselData.count - 1)
        
        CarouselGroupUserDefaults.set(row, forKey: CarouselNotificationExtension.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_DEEP_LINK_ID)
        
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

//
//  CarouselCell.swift
//  NotificationContentExtension
//
//  Created by Yan Malinovsky on 08.03.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import UIKit

class CarouselCell: UICollectionViewCell {
        
    private var imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    
    static let cellID = "CarouselCell"
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }
    
    private func setupUI() {
        self.backgroundColor = .clear
        
        self.contentView.addSubview(self.activityIndicator)
        
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.contentView.addSubview(self.imageView)
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        self.imageView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        self.imageView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        self.imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
    }
    
    func configure(image: UIImage?) {
        if let image = image {
            self.activityIndicator.stopAnimating()
            self.imageView.image = image
        } else {
            self.activityIndicator.startAnimating()
        }
    }
}

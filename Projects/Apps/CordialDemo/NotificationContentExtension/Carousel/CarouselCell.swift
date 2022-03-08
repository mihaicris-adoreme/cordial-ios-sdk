//
//  CarouselCell.swift
//  NotificationContentExtension
//
//  Created by Yan Malinovsky on 08.03.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import UIKit

class CarouselCell: UICollectionViewCell {
    
    // MARK: - SubViews
    
    private lazy var imageView = UIImageView()
    
    // MARK: - Properties
    
    static let cellID = "CarouselCell"
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }
}

// MARK: - Setups

private extension CarouselCell {
    func setupUI() {
        backgroundColor = .clear
        
        addSubview(self.imageView)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        self.imageView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        self.imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        self.imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.imageView.layer.cornerRadius = 24
        
    }
}

// MARK: - Public

extension CarouselCell {
    public func configure(image: UIImage?) {
        self.imageView.image = image
    }
}

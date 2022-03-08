//
//  CarouselView.swift
//  NotificationContentExtension
//
//  Created by Yan Malinovsky on 08.03.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import UIKit

class CarouselView: UIView {
    
    struct CarouselData {
        let image: UIImage?
    }
    
    // MARK: - Subviews
    
    private lazy var carouselCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.dataSource = self
        collection.delegate = self
        collection.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.cellID)
        collection.backgroundColor = .clear
        
        return collection
    }()
    
    
    // MARK: - Properties
    
    private var pages: Int
    private var carouselData = [CarouselData]()
    private var currentPage = 0
    
    // MARK: - Initializers
    
    init(pages: Int) {
        self.pages = pages
        super.init(frame: .zero)
        
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setups

private extension CarouselView {
    func setupUI() {
        backgroundColor = .clear
        self.setupCollectionView()
    }
    
    func setupCollectionView() {
        let cellPadding = (frame.width - 300) / 2
        let carouselLayout = UICollectionViewFlowLayout()
        carouselLayout.scrollDirection = .horizontal
        carouselLayout.itemSize = .init(width: 300, height: 400)
        carouselLayout.sectionInset = .init(top: 0, left: cellPadding, bottom: 0, right: cellPadding)
        carouselLayout.minimumLineSpacing = cellPadding * 2
        self.carouselCollectionView.collectionViewLayout = carouselLayout
        
        addSubview(self.carouselCollectionView)
        self.carouselCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.carouselCollectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        self.carouselCollectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        self.carouselCollectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        self.carouselCollectionView.heightAnchor.constraint(equalToConstant: 450).isActive = true
    }

}

// MARK: - UICollectionViewDataSource

extension CarouselView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.carouselData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCell.cellID, for: indexPath) as? CarouselCell else { return UICollectionViewCell()
        }
        
        let image = self.carouselData[indexPath.row].image
        
        cell.configure(image: image)
        
        return cell
    }
}

// MARK: - UICollectionView Delegate

extension CarouselView: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentPage = getCurrentPage()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.currentPage = getCurrentPage()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.currentPage = getCurrentPage()
    }
}

// MARK: - Public

extension CarouselView {
    public func configureView(with data: [CarouselData]) {
        let cellPadding = (frame.width - 300) / 2
        let carouselLayout = UICollectionViewFlowLayout()
        carouselLayout.scrollDirection = .horizontal
        carouselLayout.itemSize = .init(width: 300, height: 400)
        carouselLayout.sectionInset = .init(top: 0, left: cellPadding, bottom: 0, right: cellPadding)
        carouselLayout.minimumLineSpacing = cellPadding * 2
        self.carouselCollectionView.collectionViewLayout = carouselLayout
        
        self.carouselData = data
        self.carouselCollectionView.reloadData()
    }
}

// MARKK: - Helpers

private extension CarouselView {
    func getCurrentPage() -> Int {
        
        let visibleRect = CGRect(origin: carouselCollectionView.contentOffset, size: carouselCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = carouselCollectionView.indexPathForItem(at: visiblePoint) {
            return visibleIndexPath.row
        }
        
        return self.currentPage
    }
}

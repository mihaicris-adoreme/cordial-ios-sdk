//
//  CarouselView.swift
//  NotificationContentExtension
//
//  Created by Yan Malinovsky on 08.03.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import UIKit

class CarouselView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var pages: Int
    private var carouselData = [CarouselData]()
    private var currentPage = 0
    
    struct CarouselData {
        let image: UIImage?
    }
    
    init(pages: Int) {
        self.pages = pages
        super.init(frame: .zero)
        
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.dataSource = self
        collection.delegate = self
        collection.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.cellID)
        collection.backgroundColor = .clear
        
        return collection
    }()
    
    private func setupUI() {
        backgroundColor = .clear
        self.setupCollectionView()
    }
    
    private func setupCollectionView() {
        let cellPadding = (frame.width - 300) / 2
        let carouselLayout = UICollectionViewFlowLayout()
        carouselLayout.scrollDirection = .horizontal
        carouselLayout.itemSize = .init(width: 300, height: 400)
        carouselLayout.sectionInset = .init(top: 0, left: cellPadding, bottom: 0, right: cellPadding)
        carouselLayout.minimumLineSpacing = cellPadding * 2
        self.collectionView.collectionViewLayout = carouselLayout
        
        addSubview(self.collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        self.collectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        self.collectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        self.collectionView.heightAnchor.constraint(equalToConstant: 450).isActive = true
    }
    
    func configureView(with data: [CarouselData]) {
        let cellPadding = (frame.width - 300) / 2
        let carouselLayout = UICollectionViewFlowLayout()
        carouselLayout.scrollDirection = .horizontal
        carouselLayout.itemSize = .init(width: 300, height: 400)
        carouselLayout.sectionInset = .init(top: 0, left: cellPadding, bottom: 0, right: cellPadding)
        carouselLayout.minimumLineSpacing = cellPadding * 2
        self.collectionView.collectionViewLayout = carouselLayout
        
        self.carouselData = data
        self.collectionView.reloadData()
    }
    
    func getCurrentPage() -> Int {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) {
            return visibleIndexPath.row
        }
        
        return self.currentPage
    }
    
    // MARK: - UICollectionViewDataSource
    
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
    
    // MARK: - UICollectionView Delegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentPage = self.getCurrentPage()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.currentPage = self.getCurrentPage()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.currentPage = self.getCurrentPage()
    }
}

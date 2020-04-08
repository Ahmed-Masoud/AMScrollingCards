//
//  SwipingCardsManager.swift
//  AMScrollingCards
//
//  Created by ahmed.ehab on 3/18/19.
//  Copyright © 2019 Rubikal. All rights reserved.
//

import Foundation
import UIKit
import FlexiblePageControl

public protocol SwipingCardsManagerDelegate: class {
    func getCellForIndexPath(cell: UICollectionViewCell, indexPath: IndexPath) -> UICollectionViewCell
    func didSelectCard(index: Int)
    func didChangeCard(index: Int)
}

public struct SwipingCardsConfigurationModel {
    var containerView: UIView
    var numberOfItems: Int
    var identifier: String
    var delegate: SwipingCardsManagerDelegate
    var cellNib: UINib
    var spacing: CGFloat = 10
    var usePageIndicator: Bool
    var selectedPageDotColor: UIColor?
    var pageDotColor: UIColor?
    var peakSize: CGFloat = 25
    
    public init(containerView: UIView,
         numberOfItems: Int,
         identifier: String,
         delegate: SwipingCardsManagerDelegate,
         cellNib: UINib,
         spacing: CGFloat = 0,
         usePageIndicator: Bool = true,
         selectedPageDotColor: UIColor?,
         pageDotColor: UIColor?,
         peakSize: CGFloat = 25) {
        self.containerView = containerView
        self.numberOfItems = numberOfItems
        self.identifier = identifier
        self.peakSize = peakSize
        self.spacing = spacing
        self.delegate = delegate
        self.cellNib = cellNib
        self.pageDotColor = pageDotColor
        self.selectedPageDotColor = selectedPageDotColor
        self.usePageIndicator = usePageIndicator
    }
}

@available(iOS 9.0, *)
public final class SwipingCardsManager: NSObject {
    
    public var cardsView: UIView!
    private var pageDotColor: UIColor!
    private var selectedPageDotColor: UIColor!
    private var collectionView: UICollectionView!
    private var collectionViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    private var numberOfItems: Int = 0
    private var indexOfCellBeforeDragging = 0
    private var lastIndex = 0
    private var pageControl: FlexiblePageControl!
    private var spacing: CGFloat!
    weak var delegate: SwipingCardsManagerDelegate?
    private var identifier: String!
    private var peakSize: CGFloat!
    private var usePageIndicator: Bool!
    
    public init(config: SwipingCardsConfigurationModel) {
        super.init()
        self.spacing = config.spacing
        cardsView = config.containerView
        self.numberOfItems = config.numberOfItems
        self.identifier = config.identifier
        self.delegate = config.delegate
        self.pageDotColor = config.pageDotColor
        self.selectedPageDotColor = config.selectedPageDotColor
        self.usePageIndicator = config.usePageIndicator
        self.peakSize = config.peakSize
        setupPageControl()
        setupCollectionView(cellNib: config.cellNib)
        configureCollectionViewLayoutItemSize()
        cardsView.clipsToBounds = false
        collectionView.clipsToBounds = false
    }
    
    private func setupPageControl() {
        pageControl = FlexiblePageControl()
        pageControl.numberOfPages = numberOfItems
        pageControl.isUserInteractionEnabled = false
        pageControl.pageIndicatorTintColor = pageDotColor
        pageControl.currentPageIndicatorTintColor = selectedPageDotColor
        setupPageControlConstraints()
    }
    
    private func setupPageControlConstraints() {
        cardsView.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.leadingAnchor.constraint(equalTo: cardsView.leadingAnchor).isActive = true
        pageControl.trailingAnchor.constraint(equalTo: cardsView.trailingAnchor).isActive = true
        pageControl.topAnchor.constraint(equalTo: cardsView.bottomAnchor).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 33).isActive = true
    }
    
    private func setupCollectionView(cellNib: UINib) {
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumLineSpacing = spacing
        collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "identifier")
        collectionView.register(cellNib, forCellWithReuseIdentifier: identifier)
        collectionView.clipsToBounds = false
        setupCollectionViewConstraints()
    }
    
    private func setupCollectionViewConstraints() {
        cardsView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: cardsView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: cardsView.trailingAnchor).isActive = true
        if usePageIndicator {
            collectionView.topAnchor.constraint(equalTo: cardsView.topAnchor).isActive = true
            collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor).isActive = true
        } else {
            collectionView.topAnchor.constraint(equalTo: cardsView.topAnchor).isActive = true
            collectionView.bottomAnchor.constraint(equalTo: pageControl.bottomAnchor).isActive = true
        }
        collectionView.layoutIfNeeded()
    }
    
    private func configureCollectionViewLayoutItemSize() {
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        collectionViewLayout.itemSize = CGSize(width: collectionViewLayout.collectionView!.frame.width - (spacing + peakSize) * 2, height: collectionViewLayout.collectionView!.frame.size.height)
    }
    
    private func indexOfMajorCell() -> Int {
        let itemWidth = collectionViewLayout.itemSize.width
        let proportionalOffset = collectionViewLayout.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let safeIndex = max(0, min(numberOfItems - 1, index))
        return safeIndex
    }
    
    public func reloadCollection(indexPaths: [IndexPath]) {
        if indexPaths.isEmpty {
            collectionView.reloadData()
        } else {
            collectionView.reloadItems(at: indexPaths)
        }
    }
}

@available(iOS 9.0, *)
extension SwipingCardsManager: UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset
        
        // calculate where scrollView should snap to:
        let indexOfMajorCell = self.indexOfMajorCell()
        
        // calculate conditions:
        let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < numberOfItems && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
        
        if didUseSwipeToSkipCell {
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        } else {
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        return delegate?.getCellForIndexPath(cell: cell, indexPath: indexPath) ?? UICollectionViewCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectCard(index: indexPath.row)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentIndex = indexOfMajorCell()
        if currentIndex != lastIndex {
            lastIndex = currentIndex
            pageControl.setCurrentPage(at: indexOfMajorCell(), animated: true)
            delegate?.didChangeCard(index: indexOfMajorCell())
        }
    }
    
    
}



extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}

extension SwipingCardsManagerDelegate {
    // making this delegate function optional
    func didChangeCard(index: Int){}
}

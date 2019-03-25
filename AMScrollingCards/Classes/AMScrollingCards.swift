//
//  SwipingCardsManager.swift
//  AMScrollingCards
//
//  Created by ahmed.ehab on 3/18/19.
//  Copyright © 2019 Rubikal. All rights reserved.
//

import Foundation
import UIKit

public protocol SwipingCardsManagerDelegate: class {
    func getCellForIndexPath(cell: UICollectionViewCell, indexPath: IndexPath) -> UICollectionViewCell
    func didSelectCard(index: Int)
    func didChangeCard(index: Int)
}

extension SwipingCardsManagerDelegate {
    // making this delegate function optional
    func didChangeCard(index: Int){}
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
    private var pageControl: UIPageControl!
    private var spacing: CGFloat!
    weak var delegate: SwipingCardsManagerDelegate?
    private var identifier: String!
    private var useInsetSpacing: Bool!
    
    public init(frame: CGRect,
                numberOfItems: Int,
                identifier: String,
                delegate: SwipingCardsManagerDelegate,
                cellNib: UINib,
                spacing: CGFloat = 0,
                selectedPageDotColor: UIColor,
                pageDotColor: UIColor,
                useInsetSpacing: Bool = false) {
        super.init()
        self.useInsetSpacing = useInsetSpacing
        self.spacing = spacing
        cardsView = UIView(frame: frame)
        self.numberOfItems = numberOfItems
        self.identifier = identifier
        self.delegate = delegate
        self.pageDotColor = pageDotColor
        self.selectedPageDotColor = selectedPageDotColor
        setupPageControl(frame: frame)
        setupCollectionView(frame: frame, cellNib: cellNib)
        configureCollectionViewLayoutItemSize()
    }
    
    private func setupPageControl(frame: CGRect) {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: frame.width, height: 33))
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
        pageControl.bottomAnchor.constraint(equalTo: cardsView.bottomAnchor).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 33)
    }
    
    private func setupCollectionView(frame: CGRect, cellNib: UINib) {
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumLineSpacing = spacing
        collectionView = UICollectionView(frame: frame, collectionViewLayout: collectionViewLayout)
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
        collectionView.topAnchor.constraint(equalTo: cardsView.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor).isActive = true
        collectionView.layoutIfNeeded()
    }
    
    private func calculateSectionInset() -> CGFloat {
        let deviceIsIpad = UIDevice.current.userInterfaceIdiom == .pad
        let deviceOrientationIsLandscape = UIDevice.current.orientation.isLandscape
        let cellBodyViewIsExpended = deviceIsIpad || deviceOrientationIsLandscape
        let cellBodyWidth: CGFloat = 236 + (cellBodyViewIsExpended ? 174 : 0)
        
        let buttonWidth: CGFloat = 50
        
        let inset = (collectionViewLayout.collectionView!.frame.width - cellBodyWidth + buttonWidth) / 4
        return inset
    }
    
    private func configureCollectionViewLayoutItemSize() {
        let inset: CGFloat = calculateSectionInset() // This inset calculation is some magic so the next and the previous cells will peek from the sides. Don't worry about it
        if useInsetSpacing {
            collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        } else {
            collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        }
        
        collectionViewLayout.itemSize = CGSize(width: collectionViewLayout.collectionView!.frame.size.width - inset * 2, height: collectionViewLayout.collectionView!.frame.size.height)
    }
    
    private func indexOfMajorCell() -> Int {
        let itemWidth = collectionViewLayout.itemSize.width
        let proportionalOffset = collectionViewLayout.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let safeIndex = max(0, min(numberOfItems - 1, index))
        return safeIndex
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
            
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = collectionViewLayout.itemSize.width * CGFloat(snapToIndex) + spacing
            
            // Damping equal 1 => no oscillations => decay animation:
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                scrollView.layoutIfNeeded()
            }, completion: nil)
            
        } else {
            // This is a much better way to scroll to a cell:
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
            pageControl.currentPage = indexOfMajorCell()
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

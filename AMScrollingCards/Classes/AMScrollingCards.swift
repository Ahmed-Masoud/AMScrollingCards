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

extension SwipingCardsManagerDelegate {
    // making this delegate function optional
    func didChangeCard(index: Int){}
}

public struct SwipingCardsConfigurationModel {
    var containerView: UIView
    var numberOfItems: Int
    var identifier: String
    var delegate: SwipingCardsManagerDelegate
    var cellNib: UINib
    var spacing: CGFloat
    var usePageIndicator: Bool
    var selectedPageDotColor: UIColor
    var pageDotColor: UIColor
    var peakSize: CGFloat
    var shouldUseScaleAnimation: Bool
    
    public init(containerView: UIView,
                numberOfItems: Int,
                identifier: String,
                delegate: SwipingCardsManagerDelegate,
                cellNib: UINib,
                spacing: CGFloat = 10,
                usePageIndicator: Bool = true,
                selectedPageDotColor: UIColor,
                pageDotColor: UIColor,
                peakSize: CGFloat = 25,
                shouldUseScaleAnimation: Bool = true) {
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
        self.shouldUseScaleAnimation = shouldUseScaleAnimation
    }
}

@available(iOS 9.0, *)
public class SwipingCardsManager: NSObject {
    private var config: SwipingCardsConfigurationModel!
    private var cardsView: UIView!
    private var collectionView: UICollectionView!
    private var collectionViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    private var indexOfCellBeforeDragging = 0
    private var lastIndex = 0
    private var lastOffset: CGFloat = 0
    private var pageControl: FlexiblePageControl!
    weak var delegate: SwipingCardsManagerDelegate?
    
    public init(config: SwipingCardsConfigurationModel) {
        super.init()
        self.config = config
        cardsView = config.containerView
        self.delegate = config.delegate
    }
    
    //MARK: Public methods
    
    public func showCards() {
        UIView.animate(withDuration: 0, animations: { [weak self] in
            guard let self = self else { return }
            self.setupUI()
        }) { [weak self] (_) in
            guard let self = self else { return }
            if self.config.shouldUseScaleAnimation {
                self.animateScaling()
            }
        }
    }
    
    public func reloadCollection(indexPaths: [IndexPath]) {
        if indexPaths.isEmpty {
            collectionView.reloadData()
        } else {
            collectionView.reloadItems(at: indexPaths)
        }
    }
    
    /// Scroll to item at index, will do nothing if index > config.numberOfItems or index < 0
    /// - Parameters:
    ///   - indexPath: Int row value to scroll to
    ///   - at: at item position UICollectionView.ScrollPosition default = .centeredHorizontally
    ///   - animated: Bool for animated scroll. Default = true
    public func scrollTo(index:Int, at: UICollectionView.ScrollPosition = .centeredHorizontally,animated:Bool = true) {
        guard index >= 0, index < config.numberOfItems else { return }
        let duration = animated ? 0.2 : 0.0
        UIView.animate(withDuration: duration, animations: {
            [weak self] in
            self?.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: at, animated: false)
        }) { [weak self] (_) in
            guard let self = self else { return }
            self.lastOffset = self.collectionViewLayout.collectionView!.contentOffset.x
            self.lastIndex = self.indexOfMajorCell()
            self.pageControl.setCurrentPage(at: self.lastIndex, animated: true)
            self.delegate?.didChangeCard(index: self.lastIndex)
            if self.config.shouldUseScaleAnimation { self.animateScaling() }
        }
    }
    
    /// Scroll to next item, will do nothing if next item index > config.numberOfItems or next item index < 0
    /// - Parameters:
    ///   - indexPath: Int row value to scroll to
    ///   - at: at item position UICollectionView.ScrollPosition. Default = .centeredHorizontally
    ///   - animated: Bool for animated scroll. Default = true
    public func scrollToNext(at: UICollectionView.ScrollPosition = .centeredHorizontally,animated:Bool = true) {
        let nextIndex = indexOfMajorCell()+1
        scrollTo(index: nextIndex, at: at, animated: animated)
    }
    
    /// Scroll to previous item, will do nothing if previous item index > config.numberOfItems or previous item index < 0
    /// - Parameters:
    ///   - indexPath: Int row value to scroll to
    ///   - at: at item position UICollectionView.ScrollPosition default = .centeredHorizontally
    ///   - animated: Bool for animated scroll. Default = true
    public func scrollToPrevious(at: UICollectionView.ScrollPosition = .centeredHorizontally,animated:Bool = true) {
        let previousIndex = indexOfMajorCell()-1
        scrollTo(index: previousIndex, at: at, animated: animated)
    }
    
    //MARK: Private methods
    
    private func setupUI() {
        setupPageControl()
        setupCollectionView()
        configureCollectionViewLayoutItemSize()
        cardsView.clipsToBounds = false
        collectionView.clipsToBounds = false
    }
    
    private func setupPageControl() {
        pageControl = FlexiblePageControl()
        pageControl.numberOfPages = config.numberOfItems
        pageControl.isUserInteractionEnabled = false
        pageControl.pageIndicatorTintColor = config.pageDotColor
        pageControl.currentPageIndicatorTintColor = config.selectedPageDotColor
        setupPageControlConstraints()
    }
    
    private func setupPageControlConstraints() {
        cardsView.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.leadingAnchor.constraint(equalTo: cardsView.leadingAnchor).isActive = true
        pageControl.trailingAnchor.constraint(equalTo: cardsView.trailingAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: cardsView.bottomAnchor).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 33).isActive = true
    }
    
    private func setupCollectionView() {
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumLineSpacing = config.spacing
        collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "identifier")
        collectionView.register(config.cellNib, forCellWithReuseIdentifier: config.identifier)
        collectionView.clipsToBounds = false
        setupCollectionViewConstraints()
    }
    
    private func setupCollectionViewConstraints() {
        cardsView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: cardsView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: cardsView.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: cardsView.topAnchor).isActive = true
        if config.usePageIndicator {
            collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor).isActive = true
        } else {
            collectionView.bottomAnchor.constraint(equalTo: cardsView.bottomAnchor).isActive = true
            pageControl.isHidden = true
        }
        collectionView.layoutIfNeeded()
    }
    
    private func configureCollectionViewLayoutItemSize() {
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: config.spacing, bottom: 0, right: config.spacing)
        collectionViewLayout.itemSize = CGSize(width: collectionViewLayout.collectionView!.frame.width - (config.spacing + config.peakSize) * 2, height: collectionViewLayout.collectionView!.frame.size.height)
    }
    
    private func indexOfMajorCell() -> Int {
        let itemWidth = collectionViewLayout.itemSize.width
        let proportionalOffset = (collectionViewLayout.collectionView!.contentOffset.x) / itemWidth
        var index = 0
        if lastOffset > collectionViewLayout.collectionView!.contentOffset.x {
            index = Int(proportionalOffset)
        } else {
            index = Int(round(proportionalOffset))
        }
        let safeIndex = max(0, min(config.numberOfItems - 1, index))
        return safeIndex
    }
    
    private func animateScaling() {
        let cell = collectionView.cellForItem(at: IndexPath(row: indexOfMajorCell(), section: 0))
        let visibleCells = collectionView.visibleCells.filter({$0 != cell})
        var scaleUpTransform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        var scaleDownTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            if self.indexOfMajorCell() == 0 {
                scaleUpTransform = scaleUpTransform.translatedBy(x: 10, y: 0)
                scaleDownTransform = scaleDownTransform.translatedBy(x: 10, y: 0)
                cell?.transform = scaleUpTransform
            } else if self.indexOfMajorCell() == (self.config.numberOfItems - 1) {
                scaleUpTransform = scaleUpTransform.translatedBy(x: -10, y: 0)
                scaleDownTransform = scaleDownTransform.translatedBy(x: -10, y: 0)
                cell?.transform = scaleUpTransform
            } else {
                cell?.transform = scaleUpTransform
            }
            visibleCells.forEach({$0.transform = scaleDownTransform})
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
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < config.numberOfItems && velocity.x > swipeVelocityThreshold
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
        return config.numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: config.identifier, for: indexPath)
        if config.shouldUseScaleAnimation {
            let scaleDownTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            UIView.animate(withDuration: 0.2) {
                cell.transform = scaleDownTransform
            }
        }
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
            if config.shouldUseScaleAnimation { animateScaling() }
            lastOffset = collectionViewLayout.collectionView!.contentOffset.x
        }
        
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var scaleDownTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        if config.shouldUseScaleAnimation {
            if self.indexOfMajorCell() == 0 {
                scaleDownTransform = scaleDownTransform.translatedBy(x: 10, y: 0)
            } else if self.indexOfMajorCell() == (self.config.numberOfItems - 1) {
                scaleDownTransform = scaleDownTransform.translatedBy(x: -10, y: 0)
            }
            let visibleCells = collectionView.visibleCells.filter({$0 != collectionView.cellForItem(at: IndexPath(row: indexOfMajorCell(), section: 0))})
            visibleCells.forEach({$0.transform = scaleDownTransform})
        }
    }
}



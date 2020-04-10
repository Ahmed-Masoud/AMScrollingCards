//
//  ViewController.swift
//  AMScrollingCards
//
//  Created by Ahmed-Masoud-R on 03/19/2019.
//  Copyright (c) 2019 Ahmed-Masoud-R. All rights reserved.
//

import UIKit
import AMScrollingCards

struct CardData {
    var color: UIColor
    var title: String
}

class ViewController: UIViewController {

    @IBOutlet weak var scrollingCardsContainer: UIView!
    var swipingCardsManager: SwipingCardsManager!
    var data: [CardData] = [CardData]()
    var scrollingCardsView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Dummy Data
        data.append(CardData(color: UIColor.red, title: "Card 1"))
        data.append(CardData(color: UIColor.yellow, title: "Card 2"))
        data.append(CardData(color: UIColor.green, title: "Card 3"))
        data.append(CardData(color: UIColor.red, title: "Card 1"))
        data.append(CardData(color: UIColor.yellow, title: "Card 2"))
        data.append(CardData(color: UIColor.green, title: "Card 3"))
        data.append(CardData(color: UIColor.red, title: "Card 1"))
        data.append(CardData(color: UIColor.yellow, title: "Card 2"))
        data.append(CardData(color: UIColor.green, title: "Card 3"))
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /*
         Initialize instance of manager by passing
         ================================================
         1. the enclosing View
         2. number of cards
         3. custom cell identifier
         4. delegate
         5. nib file of custom cell
         6. spacing between cards defaults to 10
         7. if module should add a page indicator
         8. page indicator colors
         9. peak size
         10. if the cards should use animation to focus on selected card
         =================================================
         */
        let config = SwipingCardsConfigurationModel(containerView: scrollingCardsContainer ,numberOfItems: data.count,identifier: "cardCell", delegate: self, cellNib: UINib.init(nibName: "CustomCollectionViewCell", bundle: nil), spacing: 10, usePageIndicator: true, selectedPageDotColor: UIColor.red, pageDotColor: UIColor.blue, peakSize: 25, shouldUseScaleAnimation: true)
        swipingCardsManager = SwipingCardsManager(config: config)
        swipingCardsManager.showCards()
        
    }

}

extension ViewController: SwipingCardsManagerDelegate {
    
    func getCellForIndexPath(cell: UICollectionViewCell, indexPath: IndexPath) -> UICollectionViewCell {
        let cardData = data[indexPath.row]
        if let cell = cell as? CustomCollectionViewCell {
            cell.myLabel.text = cardData.title
            cell.myView.backgroundColor = cardData.color
        }
        return cell
    }
    
    func didSelectCard(index: Int) {
        print("Selected Card At index -> \(index)")
    }
    
    func didChangeCard(index: Int) {
        print("current index \(index)")
    }
}


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
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /*
         Initialize instance of manager by passing
         ================================================
         1. the enclosing frame
         2. number of cards
         3. custom cell identifier
         4. delegate
         5. nib file of custom cell
         =================================================
         */
        swipingCardsManager = SwipingCardsManager(frame: scrollingCardsContainer.bounds ,numberOfItems: data.count,identifier: "cardCell", delegate: self, cellNib: UINib.init(nibName: "CustomCollectionViewCell", bundle: nil))
        // grab cards view
        scrollingCardsView = swipingCardsManager.cardsView
        // add subview and constraints
        scrollingCardsContainer.addSubview(scrollingCardsView)
        scrollingCardsView.translatesAutoresizingMaskIntoConstraints = false
        scrollingCardsView.leadingAnchor.constraint(equalTo: scrollingCardsContainer.leadingAnchor).isActive = true
        scrollingCardsView.trailingAnchor.constraint(equalTo: scrollingCardsContainer.trailingAnchor).isActive = true
        scrollingCardsView.topAnchor.constraint(equalTo: scrollingCardsContainer.topAnchor).isActive = true
        scrollingCardsView.bottomAnchor.constraint(equalTo: scrollingCardsContainer.bottomAnchor).isActive = true
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


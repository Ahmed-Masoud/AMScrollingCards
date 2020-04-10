# AMScrollingCards

[![Version](https://img.shields.io/cocoapods/v/AMScrollingCards.svg?style=flat)](https://cocoapods.org/pods/AMScrollingCards)
[![License](https://img.shields.io/cocoapods/l/AMScrollingCards.svg?style=flat)](https://cocoapods.org/pods/AMScrollingCards)
[![Platform](https://img.shields.io/cocoapods/p/AMScrollingCards.svg?style=flat)](https://cocoapods.org/pods/AMScrollingCards)

## Requirements
Ios 9+

## Installation

AMScrollingCards is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AMScrollingCards'
```
## Description
This pod was created to offer a ui component of paginated swiping horizontal cards with a focusing animation on the currently selected card with a peek of next and previous cards using a collection view to make sure its reliable and memory efficient

## Demo
![Alt Text](https://media.giphy.com/media/W2nP3cW7U4GbW6mswK/giphy.gif)

## Usage
```swift
/*
         Initialize Configuration instance of manager by passing
         ================================================
         1. the enclosing View for the cards
         2. number of cards
         3. custom cell identifier
         4. delegate
         5. nib file of the custom cell
         6. spacing between cards defaults to 10
         7. if module should add a page indicator
         8. page indicator colors
         9. peak size which is the size of the left and right cards that should be shown
         10. if the cards should use animation to focus on selected card
         =================================================
*/
let config = SwipingCardsConfigurationModel(containerView: scrollingCardsContainer ,
                                                    numberOfItems: data.count,
                                                    identifier: "cardCell",
                                                    delegate: self,
                                                    cellNib: UINib.init(nibName: "CustomCollectionViewCell",bundle: nil),
                                                    spacing: 10,
                                                    usePageIndicator: false,
                                                    selectedPageDotColor: UIColor.red,
                                                    pageDotColor: UIColor.blue,
                                                    peakSize: 25,
                                                    shouldUseScaleAnimation: true)
// init module mannager
swipingCardsManager = SwipingCardsManager(config: config)
// simply show the cards
swipingCardsManager.showCards()
````

## Delegate
```
    func getCellForIndexPath(cell: UICollectionViewCell, indexPath: IndexPath) -> UICollectionViewCell {
        // create cell of the nib file you passed inn the cofig 
        return cell
    }
    // To be called when a card is tapped
    func didSelectCard(index: Int) {
        print("Selected Card At index -> \(index)")
    }
    // to be called each time a card is swiped and being focused
    func didChangeCard(index: Int) {
        print("current index \(index)")
    }
```

## Credits
https://medium.com/@shaibalassiano/tutorial-horizontal-uicollectionview-with-paging-9421b479ee94

## License
AMScrollingCards is available under the MIT license. See the LICENSE file for more info.

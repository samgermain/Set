//
//  Deck.swift
//  Set
//
//  Created by Samuel Germain on 2019-10-25.
//  Copyright © 2019 Sam G. All rights reserved.
//

import Foundation

class Deck{
    var cards = [Card]()
    var isEmpty: Bool{
        get{
            return cards.count < 1
        }
    }
    
    init(){
        for color in Color.allCases{
            for shape in Shape.allCases{
                for fill in Fill.allCases{
                    for quantity in Quantity.allCases{
                        cards.append(Card(color: color, shape: shape, fill: fill, quantity: quantity))
                    }
                }
            }
        }
        cards.shuffle()
    }
    
    func drawThree() -> (Card,Card,Card){
        let card1 = cards.remove(at: 0)
        let card2 = cards.remove(at: 0)
        let card3 = cards.remove(at: 0)
        return (card1, card2, card3)
    }
    
}

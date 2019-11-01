//
//  Board.swift
//  Set
//
//  Created by Samuel Germain on 2019-10-25.
//  Copyright © 2019 Sam G. All rights reserved.
//

import Foundation

class Board{
    var cards = [Card]()
    var cardRemovalQueue = RemovalQueue()
    var hasRoom: Bool{
        get{
            return cards.count<=23
        }
    }
    var hasMatchedCards: Bool{
        get{
            return cardRemovalQueue.queue.count > 0
        }
    }
    
    func add(card: Card){
        if let matchedIndex = cardRemovalQueue.remove(){
            cards[matchedIndex] = card
        }else if hasRoom{
            cards.append(card)
        }
    }
    
}

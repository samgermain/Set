//
//  Set.swift
//  Set
//
//  Created by Samuel Germain on 2019-10-25.
//  Copyright © 2019 Sam G. All rights reserved.
//

import Foundation

class SetGame: NSObject{
    var deck = Deck()
    @objc dynamic var score = 0
    var board = Board()
    var selectedCards: [Card]{
        get{
            var cards = [Card]()
            for card in board.cards{
                if card.isSelected{
                    cards.append(card)
                }
            }
            return cards
        }
    }
    
    /**
     Places three cards on the board
     */
    func drawThree(){
        if (board.hasRoom || board.hasMatchedCards) && !deck.isEmpty{
            let (card1, card2, card3) = deck.drawThree()
            for card in [card1, card2, card3]{
                board.add(card: card)
            }
        }
    }

    /**
        Returns true if the card selected creates a match, false if it creates a mismatch, nil if less than three cards have been selected
        @index: The index of the card selected
     */
    func selectCard(at index: Int){
        //Mismatches only show temporarily and then change so the card is deselected
        for card in board.cards{
            if card.isMismatched{
                card.deselect()
            }
        }
        //Tapping on an already selected card deselects it
        if board.cards[index].isSelected{
            board.cards[index].deselect()
            score += Score.deselect
        }else if board.cards[index].isMatched{  //You cannot change the state of matched cards
            return
        }else{
            board.cards[index].select()
            if selectedCards.count >= 3{
                if match(selectedCards[0], selectedCards[1], selectedCards[2]){
                    for card in selectedCards{
                        card.match()
                        card.match()
                        card.match()
                    }
                    score += Score.match
                }else{
                    for card in selectedCards{
                        card.misMatch()
                        card.misMatch()
                        card.misMatch()
                    }
                    score += Score.mismatch
                }
            }
        }
    }
    
    /**
     Change observed values so that the view updates before a new game is created
     */
    func prepareForNewGame(){
        self.score = 0
    }
    
    private func match(_ card1: Card, _ card2: Card, _ card3: Card) -> Bool{
        if colorMatch(card1, card2, card3)
        && shapeMatch(card1, card2, card3)
        && fillMatch(card1, card2, card3)
        && quantityMatch(card1, card2, card3){
            for index in board.cards.indices{
                let card = board.cards[index]
                if card == card1 || card == card2 || card == card3{
                    board.cardRemovalQueue.add(index)   //Schedule matched cards for removal from the board
                }
            }
            return true
        }else{
            return false
        }
    }
    
    /**
     A match if all three cards have the same color, or all three cards have different colors
     */
    private func colorMatch(_ card1: Card, _ card2: Card, _ card3: Card) -> Bool{
        if (card1.color == card2.color || card1.color == card3.color || card2.color == card3.color){
            if (card1.color != card2.color || card1.color != card3.color || card2.color != card3.color){
                return false
            }else{
                return true
            }
        }
        return true
    }

    /**
     A match if all three cards have the same shape, or all three cards have different shapes
     */
    private func shapeMatch(_ card1: Card, _ card2: Card, _ card3: Card) -> Bool{
        if (card1.shape == card2.shape || card1.shape == card3.shape || card2.shape == card3.shape){
            if (card1.shape != card2.shape || card1.shape != card3.shape || card2.shape != card3.shape){
                return false
            }else{
                return true
            }
        }
        return true
    }
    
    /**
     A match if all three cards have the same fill, or all three cards have different fills
     */
    private func fillMatch(_ card1: Card, _ card2: Card, _ card3: Card) -> Bool{
        if (card1.fill == card2.fill || card1.fill == card3.fill || card2.fill == card3.fill){
            if (card1.fill != card2.fill || card1.fill != card3.fill || card2.fill != card3.fill){
                return false
            }else{
                return true
            }
        }
        return true
    }
    
    /**
     A match if all three cards have the same quantity, or all three cards have different quantities
     */
    private func quantityMatch(_ card1: Card, _ card2: Card, _ card3: Card) -> Bool{
        if (card1.quantity == card2.quantity || card1.quantity == card3.quantity || card2.quantity == card3.quantity){
            if (card1.quantity != card2.quantity || card1.quantity != card3.quantity || card2.quantity != card3.quantity){
                return false
            }else{
                return true
            }
        }
        return true
    }
    
   override init(){
        super.init()
        drawThree()
        drawThree()
        drawThree()
        drawThree()
    }
    
}

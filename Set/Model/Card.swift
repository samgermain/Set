//
//  Card.swift
//  Set
//
//  Created by Samuel Germain on 2019-10-25.
//  Copyright © 2019 Sam G. All rights reserved.
//

import Foundation
import UIKit.UIColor

enum Color: String, CaseIterable{
    case Red
    case Green
    case Purple
}

enum Shape: String, CaseIterable{
    case diamond
    case circle = "●"
    case squiggle
}

enum Fill: Int, CaseIterable{
    case striped = 5
    case empty = -20
    case solid = 20
}

enum Quantity: Int, CaseIterable{
    case one = 1
    case two = 2
    case three = 3
}

/**
 The value is the color to make the border of the card when the card is in that state
 */
enum State: String{
    case matched = "Green"
    case misMatched = "Red"
    case selected = "Blue"
    case unSelected = "Yellow"
}

class Card: Hashable{
    private(set) var state = State.unSelected
    private(set) var color: Color
    private(set) var shape: Shape
    private(set) var fill: Fill
    private(set) var quantity: Quantity
    private(set) var identifier: Int?
    var isSelected: Bool {
        return state == State.selected
    }
    var isMatched: Bool {
        return state == State.matched
    }
    var isMismatched: Bool {
        return state == State.misMatched
    }
    
    init(color: Color, shape: Shape, fill: Fill, quantity: Quantity){
        self.color = color
        self.shape = shape
        self.fill = fill
        self.quantity = quantity
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(color)
        hasher.combine(shape)
        hasher.combine(fill)
        hasher.combine(quantity)
    }
    
    static func ==(lhs: Card, rhs: Card) -> Bool{
        return lhs.color == rhs.color
            && lhs.shape == rhs.shape
            && lhs.fill == rhs.fill
            && lhs.quantity == rhs.quantity
    }
    
    func select(){
        self.state = State.selected
    }
    
    func deselect(){
        self.state = State.unSelected
    }
    
    func match(){
        self.state = State.matched
    }
    
    func misMatch(){
        self.state = State.misMatched
    }
    
}

//
//  ViewController.swift
//  Set
//
//  Created by Samuel Germain on 2019-10-25.
//  Copyright © 2019 Sam G. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CardViewDelegate {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var cardViewHolderOuterView: UIView!
    @IBOutlet weak var cardViewHolder: UIView!
    @IBOutlet weak var cardViewHolderInnerView: UIView!
    @IBOutlet weak var cardViewHolderInnerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cardViewHolderInnerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var discardPile: UIView!
    @IBOutlet weak var setCountLabel: UILabel!
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    var cardViews = [CardView]()
    @objc var game = SetGame()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.updateViewFromModel()
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
        }) { [unowned self] _ in
            self.updateViewFromModel()
        }

    }
    
    private func updateViewFromModel(){
        var newCards = [CardView]()
        var cardViewsToRemove = [CardView]()
        for index in game.board.cards.indices{
            let card = game.board.cards[index]
            var cView: CardView
            if index > cardViews.count - 1{
                cView = CardView(frame: CGRect.zero, card: card)
                cardViews.append(cView)
                cardViewHolderInnerView.addSubview(cView)
                cView.delegate = self
                newCards.append(cView)
            }else{
                cView = cardViews[index]
            }
            cView.layer.borderColor = UIColor(named: card.state.rawValue)?.cgColor
            if card.state == State.matched{
                cardViewsToRemove.append(cView)
            }
        }
        for cView in cardViewsToRemove{
            for index in 0..<cardViews.count{
                if cardViews[index] == cView{
                    cView.layer.borderWidth = 0
                    //Remove the card from the inner view and place it in the same position in the viewcontrollers view
                    let frame = cardViewHolderInnerView.convert(cView.frame, to: self.view)
                    cView.removeFromSuperview()
                    self.view.addSubview(cView)
                    cView.frame = frame
                    //Animate the card flying away slightly before snapping to discard pile
                    let push = UIPushBehavior(items: [cView], mode: .instantaneous)
                    push.angle = CGFloat(Int.random(in: 90...270))
                    push.magnitude = CGFloat(10.0)
                    push.action = { [unowned push] in
                        push.dynamicAnimator?.removeBehavior(push)
                    }
                    animator.addBehavior(push)
                    var snapPoint = discardPile.frame.origin
                    snapPoint.x = snapPoint.x + discardPile.frame.width / 2
                    snapPoint.y = snapPoint.y + discardPile.frame.height / 2
                    let snap = UISnapBehavior(item: cView, snapTo: snapPoint)
                    animator.addBehavior(snap)
                    //Animate the card resizing
                    UIView.transition(with: cView, duration: 0.6
                        , options: .curveEaseInOut, animations: {[unowned  self] in
                            cView.frame.size.width = self.discardPile.frame.size.width
                            cView.frame.size.height = self.discardPile.frame.size.height
                        },completion: {_ in
                           //TODO: Check if self should be unowned
                            //Animate the label displaying number of sets solved fading to the front
                            self.discardPile.alpha = 0.0
                            self.view.bringSubviewToFront(self.discardPile)
                            UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: {
                                self.setCountLabel.text = "\(self.game.setCount) Sets"
                                self.discardPile.alpha = 1.0
                            }, completion: {_ in
                                cView.removeFromSuperview()
                            })
                    })
                    
                    self.cardViews.remove(at: index)
                
                    break
                }
            }
        }
        let (cardW,cardH,innerViewW,innerViewH) = cardWidthHeight()

        cardViewHolderInnerViewWidth.constant = innerViewW
        cardViewHolderInnerViewHeight.constant = innerViewH
        cardViewHolderInnerView.frame = CGRect(x: cardViewHolder.frame.size.width/2 - innerViewW/2, y: cardViewHolder.frame.size.height/2 - innerViewH/2, width: innerViewW, height: innerViewH)
        let frame = view.convert(drawButton.frame, to: self.cardViewHolderInnerView)
        var x:CGFloat = 0.0
        var y:CGFloat = 0.0

        
        var delay = 0.0 //Spaces out cards being drawn from the deck
        cardViewHolderInnerView.subviews.forEach { v in

            var del = 0.0
            if newCards.contains(v as! CardView){
                del = delay
                v.frame = frame
            }
            //Animates the cards movin to new positions
            UIView.animate(withDuration: 0.6, delay: del, options: .curveEaseInOut, animations: {
                 v.frame = CGRect(x: x, y: y, width: cardW, height: cardH)  //To fit the maximum amount of cards, the frame is adjusted for each card
            }, completion: {_ in
                if newCards.contains(v as! CardView){   //If this card was just drawn
                    UIView.transition(with: v, duration: 0.6, options: .transitionFlipFromLeft, animations: {
                    (v as! CardView).isFaceDown = false
                    })
                }
            })

            //places cards side by side and row by row
            x += cardW
            if x + cardW > innerViewW + 1.0 {
                x = 0.0
                y += cardH
            }
            if newCards.contains(v as! CardView){
                delay += 0.1    //There will only be a time gap for animations of cards being drawn from the deck
            }
            
        }
        
    }
    
    /**
     Calculate the width and height of each card, and the width and height of the container holding the cards
     Return: CardWidth, CardHeight, ContainerWidth, ContainerHeight
     */
    func cardWidthHeight() -> (CGFloat, CGFloat, CGFloat,CGFloat){
        let containerWidth = cardViewHolder.frame.size.width
        var containerHeight = cardViewHolder.frame.size.height
        let numItems = CGFloat(cardViewHolderInnerView.subviews.count)
        
        var numCols = numItems
        var numRows: CGFloat = 1
        var w = containerWidth / numCols
        var h = w * 8.0 / 5.0
        var prevW1: CGFloat = w
        var prevH1: CGFloat = h
        var prevCols1: CGFloat = numCols
        var prevRows1: CGFloat = numRows
        
        if h > containerHeight {
            h = containerHeight
            w = h * 5.0 / 8.0
        }
        
         while h * numRows < containerHeight, numCols > 1 {
             prevCols1 = numCols
             prevRows1 = numRows
             prevW1 = w
             prevH1 = h
             numCols -= 1
             numRows = ceil(numItems / numCols)
             w = containerWidth / numCols
             h = w * 8.0 / 5.0
         }
        
        
        
        numRows = numItems
        numCols = 1
        // get the width and height of a single item
        h = containerHeight / numRows
        w = h * 5.0 / 8.0
        
        if w > containerWidth {
            w = containerWidth / numCols
            h = w * 8.0 / 5.0
        }
        
        var prevCols2: CGFloat = numCols
        var prevRows2: CGFloat = numRows
        var prevW2: CGFloat = w
        var prevH2: CGFloat = h

        while w * numCols < containerWidth, numRows > 1 {
             prevRows2 = numRows
             prevCols2 = numCols
             prevH2 = h
             prevW2 = w
             numRows -= 1
             numCols = ceil(numItems / numRows)
             h = containerHeight / numRows
             w = h * 5.0 / 8.0
         }
        
        
        
        
        
        var cardW: CGFloat = 0
        var cardH: CGFloat = 0
        var finalCols: CGFloat = 0
        var finalRows: CGFloat = 0
        
        if prevH2 * prevW2 > prevH1 * prevW1 {
            cardW = prevW2
            cardH = prevH2
            finalCols = prevCols2
            finalRows = prevRows2
        } else {
            cardW = prevW1
            cardH = prevH1
            finalCols = prevCols1
            finalRows = prevRows1
        }

        // resulting width and height of the items
        let innerViewW: CGFloat = cardW * finalCols
        let innerViewH: CGFloat = cardH * finalRows
        
        return (cardW,cardH,innerViewW,innerViewH)
        
        
    }
    
    
    func selectCard(from view: CardView) {
       if let cardNumber = cardViews.firstIndex(of: view){
            game.selectCard(at: cardNumber)
            self.updateViewFromModel()
        }
        var cardsToRemove = [Card]()
        for card in game.board.cards{
            if card.isMatched{
                cardsToRemove.append(card)
            }
        }
        for card in cardsToRemove{
            for index in game.board.cards.indices{
                if card == game.board.cards[index]{
                    game.board.cards.remove(at: index)
                    break
                }
            }
        }
    }
    
    /**
     Draws 3 cards and places them on the board
     */
    @IBAction func drawThree(_ sender: UIButton) {
        game.drawThree()
        updateViewFromModel()
    }
    @IBAction func newGame(_ sender: UIButton) {
        cardViewHolderInnerView.subviews.forEach { $0.removeFromSuperview() }
        game = SetGame()
        self.setCountLabel.text = "\(self.game.setCount) Sets"
        self.cardViews = [CardView]()
        self.updateViewFromModel()
    }
    
}


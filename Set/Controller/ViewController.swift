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
    @IBOutlet weak var cardViewHolder: UIView!
    @IBOutlet weak var cardViewHolderInnerView: UIView!
    @IBOutlet weak var cardViewHolderInnerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cardViewHolderInnerViewWidth: NSLayoutConstraint!
    
    var cardViews = [CardView]()
    @objc var game = SetGame()
    private var scoreObs: NSKeyValueObservation?    //KVO for the score
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for cView in cardViews{
            cView.layer.borderWidth = 3
        }
        self.setObservation()
        updateViewFromModel()
        for card in self.cardViews{
            card.delegate = self
        }
        
    }

    /**
     Assigns a KVO observer to watch the score value from the model
     */
    private func setObservation(){
        self.scoreObs = self.observe(\.game.score) { _, _ in
            self.scoreLabel.text = "Score: \(self.game.score)"
        }
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
        for index in game.board.cards.indices{
            let frame = CGRect(x: 50, y: 50, width: 50, height: 80)
            if index > cardViews.count - 1{
                cardViews.append(CardView(frame: frame))
            }
            let cView = cardViews[index]
            let card = game.board.cards[index]

            cView.setAttributes(card: card)
            cView.layer.borderColor = UIColor(named: card.state.rawValue)?.cgColor
            if !cardViewHolderInnerView.subviews.contains(cView){
                cardViewHolderInnerView.addSubview(cView)
            }
        }
            
        let (cardW,cardH,innerViewW,innerViewH) = cardWidthHeight()

        cardViewHolderInnerViewWidth.constant = innerViewW
        cardViewHolderInnerViewHeight.constant = innerViewH
        var x:CGFloat = 0.0
        var y:CGFloat = 0.0

            
        cardViewHolderInnerView.subviews.forEach { v in

            v.frame = CGRect(x: x, y: y, width: cardW, height: cardH)
            x += cardW
            if x + cardW > innerViewW + 1.0 {
                x = 0.0
                y += cardH
            }

        }
            //cView.isHidden = false
            //Way to tell if you've made a match, mismatch or selection
        
    }
    
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
    
    /**
     Sets the model up with a new game
     */
    private func resetModel(){
        cardViewHolderInnerView.subviews.forEach { $0.removeFromSuperview() }
        game.prepareForNewGame()
        scoreObs = nil
        game = SetGame()
        self.setObservation()
    }
    
    func selectCard(from view: CardView) {
       if let cardNumber = cardViews.firstIndex(of: view){
            game.selectCard(at: cardNumber)
            self.updateViewFromModel()
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
        self.resetModel()
        self.updateViewFromModel()
        for cView in 12..<cardViews.count{
            self.cardViews[cView].isHidden = true
        }
    }
    
}


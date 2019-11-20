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
            
            let (w,h) = cardWidthHeight()
            var x:CGFloat = 0.0
            var y:CGFloat = 0.0
            print(w)
            print(h)
            print(cardViewHolder.frame.size.width)
            print(cardViewHolder.frame.size.height)
            
            cardViewHolderInnerView.subviews.forEach { v in

                v.frame = CGRect(x: x, y: y, width: w, height: h)
                x += w
                if x + w > cardViewHolder.frame.size.width {
                    x = 0.0
                    y += h
                }

            }
            
            //cView.isHidden = false
            //Way to tell if you've made a match, mismatch or selection
        }
    }
    
    func cardWidthHeight() -> (CGFloat, CGFloat){
        let containerWidth = cardViewHolder.frame.size.width
        let containerHeight = cardViewHolder.frame.size.height
        let numItems = CGFloat(cardViewHolderInnerView.subviews.count)
        var numCols = numItems
        var numRows: CGFloat = 1
        
        var w = containerWidth / numCols
        var h = w * 8.0 / 5.0
        
        if h > containerHeight {
            h = containerHeight
            w = h * 5.0 / 8.0
        }
        
         while h * numRows < containerHeight, numCols > 1 {
             numCols -= 1
             numRows = ceil(numItems / numCols)
             h = containerHeight / numCols
             w = h * 5.0 / 8.0
         }
        
        return (w,h)
        
        
    }
    
    /**
     Sets the model up with a new game
     */
    private func resetModel(){
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


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
    @IBOutlet var cardViews: [CardView]!
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
    
    private func updateViewFromModel(){
        for index in game.board.cards.indices{
            let cView = cardViews[index]
            let card = game.board.cards[index]

            cView.setAttributes(card: card)
            cView.layer.borderColor = UIColor(named: card.state.rawValue)?.cgColor
            cView.isHidden = false
            //Way to tell if you've made a match, mismatch or selection
        }
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
        print("test2")
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


//
//  CardView.swift
//  Set
//
//  Created by Samuel Germain on 2019-10-28.
//  Copyright © 2019 Sam G. All rights reserved.
//

import UIKit

@IBDesignable
class CardView: UIView {
    
    var quantity: Quantity = Quantity.three
    var color: Color = Color.Red
    var shape: Shape = Shape.circle
    var fill: Fill = Fill.striped
    var isFaceDown = true{
        didSet{
            setNeedsDisplay()
        }
    }
    
    weak var delegate:CardViewDelegate?
    
    init(frame: CGRect, card: Card) {
        super.init(frame: frame)
        commonInit()
        self.setAttributes(card: card)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func setAttributes(card: Card){
        self.quantity = card.quantity
        self.color = card.color
        self.shape = card.shape
        self.fill = card.fill
        setNeedsDisplay()
    }
    
    private func commonInit(){
        self.clearsContextBeforeDrawing = true
        self.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.clipsToBounds = true
        layer.borderWidth = 3.0
        layer.cornerRadius = 5
        self.clearsContextBeforeDrawing = true
        let tap = UITapGestureRecognizer(target: self, action: Selector(("selectCard")))
        self.addGestureRecognizer(tap)
    }
    
    @objc func selectCard(){
        delegate?.selectCard(from: self)
    }

    
    override func draw(_ rect: CGRect){
        print("test1")
        if isFaceDown{
            print("test2")
            if let faceCardImage = UIImage(named: "adventure-time"){
                faceCardImage.draw(in: bounds)
            }
        }else{
            switch(self.color){
            case(Color.Green):
                UIColor.green.set()
            case(Color.Red):
                UIColor.red.set()
            case(Color.Purple):
                UIColor.purple.set()
            }
            
            let radius = bounds.width / 4
            let centerY = (bounds.maxY - bounds.minY) / 2
            let centerX = (bounds.maxX - bounds.minX)/2
            let centerPoint = CGPoint(x: centerX, y: centerY)
            let secondPoint = CGPoint(x: centerX, y: centerY - radius - 1)
            let topPoint = CGPoint(x: centerX, y: centerY - radius*2 - 1)
            let secondLastPoint = CGPoint(x: centerX, y: centerY + radius + 1)
            let bottomPoint = CGPoint(x: centerX, y: centerY + radius*2 + 1)
            var drawPoints: [CGPoint]
            switch(quantity){
            case(.one):
                drawPoints = [centerPoint]
            case(.two):
                drawPoints = [secondPoint, secondLastPoint]
            case(.three):
                drawPoints = [centerPoint,topPoint,bottomPoint]
                }
            for point in drawPoints{
                var path: UIBezierPath
                switch(self.shape){
                case(Shape.diamond):
                    path = drawDiamond(radius: radius, center: point)
                case(Shape.circle):
                    path = drawCircle(radius: radius, center: point)
                case(Shape.squiggle):
                    path = drawSquiggle(radius: radius/2, center: point)
                }
                    
        //            UIColor.red.set()
                let lineWidth: CGFloat = 2.0
                path.lineWidth = lineWidth
                    
                switch(self.fill){
                case(.empty):
                    path.stroke()
                case(.solid):
                    path.stroke()
                    path.fill()
                case(.striped):
                    path.lineWidth = 1
                    let context = UIGraphicsGetCurrentContext()
                        context!.saveGState()
                    let stripes = createStripes(bounds: path.bounds)
                    path.addClip()
                    stripes.stroke()
                    context!.restoreGState()
                    path.stroke()
                }
                    
            }
        }
    }
        
        
        
        func drawDiamond(radius: CGFloat, center: CGPoint) -> UIBezierPath{
            let path = UIBezierPath()
            
            path.move(to: CGPoint(x: center.x - radius, y: center.y))
            path.addLine(to: CGPoint(x: center.x, y: center.y - radius))
            path.addLine(to: CGPoint(x: center.x + radius, y: center.y))
            path.addLine(to: CGPoint(x: center.x, y: center.y + radius))
            path.close()
            
            return path
        }
        
        private func drawCircle(radius: CGFloat, center: CGPoint) -> UIBezierPath{
            let path = UIBezierPath()
            path.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
            path.close()
            return path
        }
        
        private func drawSquiggle(radius: CGFloat, center: CGPoint) -> UIBezierPath{
            let path = UIBezierPath()
            
            path.addArc(withCenter: CGPoint(x: center.x - radius*0.75, y: center.y), radius: radius, startAngle: 0, endAngle: CGFloat.pi, clockwise: true)
            path.addLine(to: CGPoint(x: center.x - 1.25 * radius, y: center.y))
            path.addArc(withCenter: CGPoint(x: center.x - 0.75 * radius, y: center.y), radius: radius/2, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 2, clockwise: false)
            
            
            path.addArc(withCenter: CGPoint(x: center.x + radius * 0.75, y: center.y), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi*2, clockwise: true)
            path.addLine(to: CGPoint(x: center.x + 1.25 * radius, y: center.y))
            path.addArc(withCenter: CGPoint(x: center.x + radius * 0.75, y: center.y), radius: radius/2, startAngle: 0, endAngle: CGFloat.pi, clockwise: false)
            
            path.close()
            
            return path
        }
        
        private func createStripes(bounds: CGRect) -> UIBezierPath{
            let stripes = UIBezierPath()
            for x in stride(from: 0, to: bounds.size.width, by: 4){
                stripes.move(to: CGPoint(x: bounds.origin.x + x, y: bounds.origin.y ))
                stripes.addLine(to: CGPoint(x: bounds.origin.x + x, y: bounds.origin.y + bounds.size.height ))
            }
            stripes.lineWidth = 2
            return stripes
        }
}

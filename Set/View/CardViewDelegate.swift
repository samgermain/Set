//
//  CardViewDelegate.swift
//  Set
//
//  Created by Samuel Germain on 2019-10-28.
//  Copyright © 2019 Sam G. All rights reserved.
//

import UIKit.UIView

protocol CardViewDelegate: AnyObject{
    func selectCard(from view: CardView)
}

//
//  RemovalQueue.swift
//  Set
//
//  Created by Samuel Germain on 2019-10-25.
//  Copyright © 2019 Sam G. All rights reserved.
//

import Foundation

class RemovalQueue{
    var queue = [Int]()
    
    func add(_ num: Int){
        queue.append(num)
    }
    
    func remove() -> Int?{
        if queue.isEmpty{
            return nil
        }else{
            return queue.remove(at: 0)
        }
    }
    
}

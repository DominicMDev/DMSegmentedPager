//
//  Extensions.swift
//  DMSegmentedControl
//
//  Created by Dominic on 9/5/18.
//  Copyright © 2018 DominicMiller. All rights reserved.
//

import UIKit

extension Array where Element == CGFloat {
    
    func sum() -> CGFloat {
        var sum: CGFloat = 0
        forEach { sum += $0 }
        return sum
    }
    
}

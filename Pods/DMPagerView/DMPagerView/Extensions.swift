//
//  Extensions.swift
//  DMPagerView
//
//  Created by Dominic Miller on 9/6/18.
//  Copyright © 2018 Dominic Miller. All rights reserved.
//

import UIKit

// MARK: - Dictionary+RemoveValuesForKeys
extension Dictionary {
    mutating func removeValues(forKeys keys: [Key]) {
        for key in keys {
            removeValue(forKey: key)
        }
    }
}


// MARK: - UIView+ReuseIdentifier
public extension UIView {
    
    internal struct Keys {
        static var ReuseIdentifier = "dm_ReuseIdentifier"
    }
    
    @objc public convenience init(reuseIdentifier: String) {
        self.init()
        objc_setAssociatedObject(self, Keys.ReuseIdentifier, reuseIdentifier, .OBJC_ASSOCIATION_COPY)
    }
    
    @objc public convenience init(frame: CGRect, reuseIdentifier: String) {
        self.init(frame: frame)
        objc_setAssociatedObject(self, Keys.ReuseIdentifier, reuseIdentifier, .OBJC_ASSOCIATION_COPY)
    }
    
    @objc public convenience init?(coder aDecoder: NSCoder, reuseIdentifier: String) {
        self.init(coder: aDecoder)
        objc_setAssociatedObject(self, Keys.ReuseIdentifier, reuseIdentifier, .OBJC_ASSOCIATION_COPY)
    }
    
    @objc public var reuseIdentifier: String? {
        return objc_getAssociatedObject(self, Keys.ReuseIdentifier) as? String
    }
    
    @objc public func prepareForReuse() {}
    
}

// MARK: - UIViewController(color: UIColor)
extension UIViewController {
    convenience init(color: UIColor) {
        self.init()
        view.backgroundColor = color
    }
}

//
//  DMPageSegue.swift
//  DMPagerView
//
//  Created by Dominic Miller on 9/6/18.
//  Copyright © 2018 Dominic Miller. All rights reserved.
//

import UIKit

/*
 *  MARK: - DMPageSegue
 */

public let DMSeguePageIdentifierFormat = "dm_page_##"

open class DMPageSegue: UIStoryboardSegue {
    public typealias SourceViewController = UIViewController & DMPageSegueSource
    
    @objc dynamic public var sourceVC: SourceViewController {
        return source as! SourceViewController
    }
    
    @objc public internal(set) var pageIndex: Int = 0
    
    private override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
    }
    
    public init(identifier: String?, source: SourceViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        pageIndex = source.pageIndex
    }
    
    override open func perform() {
        destination.willMove(toParent: sourceVC)
        sourceVC.addChild(destination)
        sourceVC.setPageViewController(destination, at: sourceVC.pageIndex)
        destination.didMove(toParent: sourceVC)
    }
    
}

/*
 *  MARK: - DMPageSegueSource
 */

@objc public protocol DMPageSegueSource: NSObjectProtocol {
    
    /**
     The destination page index.
     */
    var pageIndex: Int { get }
    
    /**
     Sets the requested page controller at the required index.
     
     - Parameter pageViewController: The page view controller.
     - Parameter index:              The page index.
     */
    @objc func setPageViewController(_ pageViewController: UIViewController, at index: Int)
}

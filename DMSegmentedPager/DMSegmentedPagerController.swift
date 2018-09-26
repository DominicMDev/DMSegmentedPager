//
//  DMSegmentedPagerController.swift
//  DMSegmentedPager
//
//  Created by Dominic on 9/12/18.
//  Copyright © 2018 DominicMiller. All rights reserved.
//

import UIKit
import DMPagerView
import DMParallaxHeader
import DMSegmentedControl

open class DMSegmentedPagerController: UIViewController, DMSegmentedPagerDelegate, DMSegmentedPagerDataSource, DMPageSegueSource {
    
    public internal(set) var pageViewControllers = [Int:UIViewController]()
    public internal(set) var pageIndex: Int = 0
    
    var _segmentedPager: DMSegmentedPager!
    public var segmentedPager: DMSegmentedPager {
        if _segmentedPager == nil {
            _segmentedPager = DMSegmentedPager()
            _segmentedPager.delegate = self
            _segmentedPager.dataSource = self
        }
        return _segmentedPager
    }
    
    override open func loadView() {
        view = segmentedPager
    }
    
    /*
     * MARK: - DMSegmentedPagerDataSource
     */
    
    open func numberOfPages(in segmentedPager: DMSegmentedPager) -> Int {
        var count = 0
        let templates = value(forKey: "storyboardSegueTemplates") as! [AnyObject]
        for template in templates {
            let segueClassName = template.value(forKey: "_segueClassName") as! String
            if segueClassName.contains(String(describing: DMPageSegue.self)) {
                count += 1
            }
        }
        return count
    }
    
    open func segmentedPager(_ segmentedPager: DMSegmentedPager, viewForPageAt index: Int) -> UIView {
        let viewController = self.segmentedPager(segmentedPager, viewControllerForPageAt: index)
        viewController.willMove(toParent: self)
        addChild(viewController)
        viewController.didMove(toParent: self)
        return viewController.view
    }
    
    open func segmentedPager(_ segmentedPager: DMSegmentedPager, viewControllerForPageAt index: Int) -> UIViewController {
        let pageViewController = pageViewControllers[index]
        if pageViewController == nil && storyboard != nil {
            let identifier = self.segmentedPager(segmentedPager, segueIdentifierForPageAt: index)
            pageIndex = index
            performSegue(withIdentifier: identifier, sender: nil)
            return pageViewControllers[index] ?? UIViewController()
        }
        return pageViewController ?? UIViewController()
    }
    
    open func segmentedPager(_ segmentedPager: DMSegmentedPager, segueIdentifierForPageAt index: Int) -> String {
        return DMSeguePageIdentifierFormat.replacingOccurrences(of: "##", with: "\(index)")
    }
    
    /*
     * MARK: - DMPageSegueSource
     */
    
    open func setPageViewController(_ pageViewController: UIViewController, at index: Int) {
        pageViewControllers[index] = pageViewController
    }
    
}

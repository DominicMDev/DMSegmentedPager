//
//  DMPagerViewController.swift
//  DMPagerView
//
//  Created by Dominic Miller on 9/6/18.
//  Copyright © 2018 Dominic Miller. All rights reserved.
//

import UIKit

public class DMPagerViewController: UIViewController, DMPagerViewDelegate, DMPagerViewControllerDataSource, DMPageSegueSource {
    var pageViewControllers = [Int:UIViewController]()
    public internal(set) var pageIndex: Int = 0
    
    var _pagerView: DMPagerView?
    public var pagerView: DMPagerView {
        if _pagerView == nil {
            _pagerView = DMPagerView()
            _pagerView!.delegate = self
            _pagerView!.dataSource = self
        }
        return _pagerView!
    }

    override public func loadView() {
        view = pagerView
    }
    
    /*
     *  MARK: - DMPagerViewControllerDataSource
     */

    public func numberOfPages(in pagerView: DMPagerView) -> Int {
        guard let segues = value(forKeyPath: "storyboardSegueTemplates") as? Array<Any> else { return 0 }
        return segues.count
    }
    
    public func pagerView(_ pagerView: DMPagerView, viewForPageAt index: Int) -> UIView {
        return self.pagerView(pagerView, viewControllerForPageAt: index).view
    }
    
    public func pagerView(_ pagerView: DMPagerView, viewControllerForPageAt index: Int) -> UIViewController {
        let pageVC = pageViewControllers[index]
        if pageVC == nil && storyboard != nil {
            self.pageIndex = index
            let identifier = self.pagerView(pagerView, segueIdentifierForPageAt: index)
            self.performSegue(withIdentifier: identifier, sender: nil)
            return self.pageViewControllers[index] ?? UIViewController(color: .white)
        }
        return pageVC ?? UIViewController(color: .white)
    }
    
    public func pagerView(_ pagerView: DMPagerView, segueIdentifierForPageAt index: Int) -> String {
        return DMSeguePageIdentifierFormat.replacingOccurrences(of: "##", with: "\(index)")
    }
    
    /*
     *  MARK: - DMPageSegueSource
     */
    
    public func setPageViewController(_ pageViewController: UIViewController, at index: Int) {
        pageViewControllers[index] = pageViewController
    }
    
}

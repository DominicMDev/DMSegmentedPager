//
//  DMPagerViewController.swift
//  DMPagerView
//
//  Created by Dominic Miller on 9/6/18.
//  Copyright © 2018 Dominic Miller. All rights reserved.
//

import UIKit

open class DMPagerViewController: UIViewController, DMPagerViewDelegate, DMPagerViewControllerDataSource, DMPageSegueSource {
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

    override open func loadView() {
        view = pagerView
    }
    
    /*
     *  MARK: - DMPagerViewControllerDataSource
     */

    open func numberOfPages(in pagerView: DMPagerView) -> Int {
        guard let segues = value(forKeyPath: "storyboardSegueTemplates") as? Array<Any> else { return 0 }
        return segues.count
    }
    
    open func pagerView(_ pagerView: DMPagerView, viewForPageAt index: Int) -> UIView {
        let viewController = self.pagerView(pagerView, viewControllerForPageAt: index)
        viewController.willMove(toParent: self)
        addChild(viewController)
        viewController.didMove(toParent: self)
        return viewController.view
    }
    
    open func pagerView(_ pagerView: DMPagerView, viewControllerForPageAt index: Int) -> UIViewController {
        let pageVC = pageViewControllers[index]
        if pageVC == nil && storyboard != nil {
            self.pageIndex = index
            let identifier = self.pagerView(pagerView, segueIdentifierForPageAt: index)
            self.performSegue(withIdentifier: identifier, sender: nil)
            return self.pageViewControllers[index] ?? UIViewController(color: .white)
        }
        return pageVC ?? UIViewController(color: .white)
    }
    
    open func pagerView(_ pagerView: DMPagerView, segueIdentifierForPageAt index: Int) -> String {
        return DMSeguePageIdentifierFormat.replacingOccurrences(of: "##", with: "\(index)")
    }
    
    /*
     *  MARK: - DMPageSegueSource
     */
    
    open func setPageViewController(_ pageViewController: UIViewController, at index: Int) {
        pageViewControllers[index] = pageViewController
    }
    
}

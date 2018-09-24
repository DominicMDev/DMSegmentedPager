//
//  DMPagerViewDelegate.swift
//  DMPagerView
//
//  Created by Dominic Miller on 9/6/18.
//  Copyright © 2018 Dominic Miller. All rights reserved.
//

import Foundation

@objc public protocol DMPagerViewDelegate: UIScrollViewDelegate {
    
    /**
     Tells the delegate that the pager is about to move to a specified page.
     
     - Parameter pagerView: A pager object informing the delegate about the impending move.
     - Parameter index:     The selected page index.
     */
    @objc optional func pagerView(_ pagerView: DMPagerView, willMoveToPage page: UIView, at index: Int)
    
    /**
     Tells the delegate that the pager did move to a specified page.
     
     - Parameter pagerView: A pager object informing the delegate about the impending move.
     - Parameter index:     The selected page index.
     */
    @objc optional func pagerView(_ pagerView: DMPagerView, didMoveToPage page: UIView, at index: Int)
    
    /**
     Tells the delegate the pager view is about to draw a page for a particular index.
     A pager view sends this message to its delegate just before it uses page to draw a index,
     thereby permitting the delegate to customize the page object before it is displayed.
     
     - Parameter pagerView: The pager-view object informing the delegate of this impending event.
     - Parameter page: A pager-view page object that pagerView is going to use when drawing the index.
     - Parameter index: An index locating the page in pagerView.
     */
    @objc optional func pagerView(_ pagerView: DMPagerView, willDisplayPage page: UIView, at index: Int)
    
    /**
     Tells the delegate that the specified page was removed from the pager.
     Use this method to detect when a page is removed from a pager view,
     as opposed to monitoring the view itself to see when it appears or disappears.
     
     - Parameter pagerView: The pager-view object that removed the view.
     - Parameter page:      The page that was removed.
     - Parameter index:     The index of the page.
     */
    @objc optional func pagerView(_ pagerView: DMPagerView, didEndDisplayingPage page: UIView, at index: Int)
    
}

/**
 DMPagerView data source protocol.
 This is adopted by an object that mediates the application’s data model for a DMPagerView object.
 The data source provides the pager object with the information it needs to construct and modify a DMPagerView view.
 
 Provides the pages to be displayed by the pager as well as informs the DMPagerView object about the number of pages.
 */
@objc public protocol DMPagerViewDataSource: NSObjectProtocol {
    
    /**
     Asks the data source to return the number of pages in the pager.
     
     - Parameter pagerView: The pager-view object that is requesting this information.
     - Returns: The number of pages in pager.
     */
    @objc func numberOfPages(in pagerView: DMPagerView) -> Int
    
    /**
     Asks the data source for a view to insert in a particular page of the pager.
     
     - Parameter pagerView: The pager-view object that is requesting the view.
     - Parameter index:     An index number identifying a page in pager-view.
     - Returns: An object inheriting from UIView that the pager can use for the specified page.
     */
    @objc func pagerView(_ pagerView: DMPagerView, viewForPageAt index: Int) -> UIView
}

/**
 The `DMPagerView`'s data source object may adopt the `DMPagerViewControllerDataSource` protocol in order to use the `DMPagerViewController` with child `UIViewController`.
 */
@objc public protocol DMPagerViewControllerDataSource: DMPagerViewDataSource {
    
    /**
     Asks the data source for a view controller to insert in a particular page of the pager-view.
     
     - Parameter pagerView: A pager-view object requesting the view.
     - Parameter index:     An index number identifying a page in pager-view.
     - Returns: An object inheriting from UIViewController that the pager-view can use for the specified page.
     */
    @objc func pagerView(_ pagerView: DMPagerView, viewControllerForPageAt index: Int) -> UIViewController
    
    /**
     Asks the data source for a segue identifier to insert in a particular page of the pager-view.
     
     - Parameter pagerView: A pager-view object requesting the view.
     - Parameter index:     An index number identifying a page in pager-view.
     - Returns: The segue identifier that the pager-view can use for the specified page.
     */
    @objc func pagerView(_ pagerView: DMPagerView, segueIdentifierForPageAt index: Int) -> String
}

//
//  DMSegmentedPagerDataSource.swift
//  DMSegmentedPager
//
//  Created by Dominic on 9/12/18.
//  Copyright © 2018 DominicMiller. All rights reserved.
//

import UIKit
import DMPagerView
import DMParallaxHeader

@objc public protocol DMSegmentedPagerDataSource: NSObjectProtocol {
    
    /**
     Asks the data source to return the number of pages in the segmented-pager.
     
     - Parameter segmentedPager: A segmented-pager object requesting this information.
     - Returns: The number of pages in segmented-pager.
     */
    @objc func numberOfPages(in segmentedPager: DMSegmentedPager) -> Int
    
    /**
     Asks the data source for a view to insert in a particular page of the segmented-pager.
     
     - Parameter segmentedPager: The segmented-pager object that is requesting the view.
     - Parameter index:          An index number identifying a page in segmented-pager.
     - Returns: An object inheriting from `UIView` that the segmented-pager can use for the specified page.
     */
    @objc func segmentedPager(_ segmentedPager: DMSegmentedPager, viewForPageAt index: Int) -> UIView
    
    /**
     Asks the data source for a title to assign to a particular page of the segmented-pager.
     The title will be used depending on the `DMSegmentedControlType` you have choosen.
     
     - Parameter segmentedPager: The segmented-pager object that is requesting the view.
     - Parameter index:          An index number identifying a page in segmented-pager.
     - Returns: The `String` title of the page in segmented-pager.
     */
    @objc optional func segmentedPager(_ segmentedPager: DMSegmentedPager, titleForSectionAt index: Int) -> String
    
    /**
     Asks the data source for a title to assign to a particular page of the segmented-pager. The title will be used depending on the `DMSegmentedControlType` you have choosen.
     
     - Parameter segmentedPager: The segmented-pager object that is requesting the view.
     - Parameter index:          An index number identifying a page in segmented-pager.
     - Returns: The `NSAttributedString` title of the page in segmented-pager.
     */
    @objc optional func segmentedPager(_ segmentedPager: DMSegmentedPager, attributedTitleForSectionAt index: Int) -> NSAttributedString
    
    /**
     Asks the data source for a image to assign to a particular page of the segmented-pager. The image will be used depending on the `DMSegmentedControlType` you have choosen.
     
     - Parameter segmentedPager: The segmented-pager object that is requesting the view.
     - Parameter index:          An index number identifying a page in segmented-pager.
     - Returns: The image of the page in segmented-pager.
     */
    @objc optional func segmentedPager(_ segmentedPager: DMSegmentedPager, imageForSectionAt index: Int) -> UIImage
    
    /**
     Asks the data source for a selected image to assign to a particular page of the segmented-pager. The image will be used depending on the `DMSegmentedControlType` you have choosen.
     
     - Parameter segmentedPager: The segmented-pager object that is requesting the view.
     - Parameter index:          An index number identifying a page in segmented-pager.
     - Returns: The selected image of the page in segmented-pager.
     */
    @objc optional func segmentedPager(_ segmentedPager: DMSegmentedPager, selectedImageForSectionAt index: Int) -> UIImage
}

extension DMSegmentedPagerDataSource where Self: DMSegmentedPagerController {
    /**
     Asks the data source for a view controller to insert in a particular page of the segmented-pager.
     
     - Parameter segmentedPager: The segmented-pager object that is requesting the view.
     - Parameter index:          An index number identifying a page in segmented-pager.
     - Returns: An object inheriting from `UIViewController` that the segmented-pager can use for the specified page.
     */
    public func segmentedPager(_ segmentedPager: DMSegmentedPager, viewControllerForPageAt index: Int) -> UIViewController {
        return UIViewController()
    }
    
    /**
     Asks the data source for a segue identifier to insert in a particular page of the segmented-pager.
     
     - Parameter segmentedPager: The segmented-pager object that is requesting the view.
     - Parameter index:          An index number identifying a page in segmented-pager.
     - Returns: The segue identifier that the segmented-pager can use for the specified page.
     */
    public func segmentedPager(_ segmentedPager: DMSegmentedPager, segueIdentifierForPageAt index: Int) -> String {
        return DMSeguePageIdentifierFormat.replacingOccurrences(of: "##", with: "\(index)")
    }
}

@objc public protocol DMSegmentedPagerDelegate: UIScrollViewDelegate {
    
    /**
     Tells the delegate that a specified view is about to be selected.
     
     - Parameter segmentedPager: The segmented-pager informing the delegate about the impending selection.
     - Parameter page:           The selected page view.
     */
    @objc optional func segmentedPager(_ segmentedPager: DMSegmentedPager, didSelectPage page: UIView)
    
    /**
     Tells the delegate that a specified title is about to be selected.
     
     - Parameter segmentedPager: A segmented-pager object informing the delegate about the impending selection.
     - Parameter title:          The selected page title.
     */
    @objc optional func segmentedPager(_ segmentedPager: DMSegmentedPager, didSelectPageWith title: String)
    
    /**
     Tells the delegate that a specified index is about to be selected.
     
     - Parameter segmentedPager: A segmented-pager object informing the delegate about the impending selection.
     - Parameter index:          The selected page index.
     */
    @objc optional func segmentedPager(_ segmentedPager: DMSegmentedPager, didSelectPageAt index: Int)
    
    
    /**
     Tells the delegate that the segmented pager is about to move to a specified page.
     
     - Parameter segmentedPager: The segmented-pager object informing the delegate about the impending move.
     - Parameter page:           The page view that the segmented-pager will move to.
     - Parameter index:          The selected page index.
     */
    @objc optional func segmentedPager(_ segmentedPager: DMSegmentedPager, willMoveToPage page: UIView, at index: Int)
    
    /**
     Tells the delegate that the segmented pager did move to a specified page.
     
     - Parameter segmentedPager: The segmented-pager object informing the delegate about the impending move.
     - Parameter page:           The page view that the segmented-pager moved to.
     - Parameter index:          The selected page index.
     */
    @objc optional func segmentedPager(_ segmentedPager: DMSegmentedPager, didMoveToPage page: UIView, at index: Int)
    
    /**
     Tells the delegate the segmented pager is about to draw a page for a particular index.
     A segmented page view sends this message to its delegate just before it uses page to draw a index, thereby permitting the delegate to customize the page object before it is displayed.
     
     - Parameter segmentedPager: The segmented-pager object informing the delegate of this impending event.
     - Parameter page:           A page view object that segmented-pager is going to use when drawing the index.
     - Parameter index:          An index locating the page in pagerView.
     */
    @objc optional func segmentedPager(_ segmentedPager: DMSegmentedPager, willDisplayPage page: UIView, at index: Int)
    
    /**
     Tells the delegate that the specified page was removed from the pager.
     Use this method to detect when a page is removed from a pager view, as opposed to monitoring the view itself to see when it appears or disappears.
     
     - Parameter segmentedPager: The segmented-pager object that removed the view.
     - Parameter page:           The page that was removed.
     - Parameter index:          The index of the page.
     */
    @objc optional func segmentedPager(_ segmentedPager: DMSegmentedPager, didEndDisplayingPage page: UIView, at index: Int)
    
    /**
     Asks the delegate to return the height of the segmented control in the segmented-pager.
     If the delegate doesn’t implement this method, 44 is assumed.
     
     - Parameter segmentedPager: A segmented-pager object informing the delegate about the impending selection.
     - Returns: A nonnegative floating-point value that specifies the height (in points) that segmented-control should be.
     */
    @objc optional func heightForSegmentedControlInSegmentedPager(_ segmentedPager: DMSegmentedPager) -> CGFloat
    
    /**
     Tells the delegate that the segmented pager has scrolled with the parallax header.
     
     - Parameter segmentedPager: A segmented-pager object in which the scrolling occurred.
     - Parameter parallaxHeader: The parallax-header that has scrolled.
     */
    @objc optional func segmentedPager(_ segmentedPager: DMSegmentedPager, didScrollWith parallaxHeader: DMParallaxHeader)
    
    /**
     Tells the delegate when dragging ended with the parallax header.
     
     - Parameter segmentedPager: A segmented-pager object that finished scrolling the content view.
     - Parameter parallaxHeader: The parallax-header that has scrolled.
     */
    @objc optional func segmentedPager(_ segmentedPager: DMSegmentedPager, didEndDraggingWith parallaxHeader: DMParallaxHeader)
    
    /**
     Asks the delegate if the segmented-pager should scroll to the top.
     If the delegate doesn’t implement this method, true is assumed.
     
     - Parameter segmentedPager: The segmented-pager object requesting this information.
     - Returns: true to permit scrolling to the top of the content, false to disallow it.
     */
    @objc optional func segmentedPagerShouldScrollToTop(_ segmentedPager: DMSegmentedPager) -> Bool
}

/**
 While using DMSegmentedPager with Parallax header, your pages can adopt the DMPageDelegate protocol to control subview's scrolling effect.
 */
@objc public protocol DMPageProtocol: NSObjectProtocol {
    
    /**
     Asks the page if the segmented-pager should scroll with the view.
     
     - Parameter segmentedPager: The segmented-pager. This is the object sending the message.
     - Parameter view:           An instance of a sub view.
     - Returns: true to allow segmented-pager and view to scroll together. The default implementation returns true.
     */
    @objc optional func segmentedPager(_ segmentedPager: DMSegmentedPager, shouldScrollWith view: UIView) -> Bool
    
}

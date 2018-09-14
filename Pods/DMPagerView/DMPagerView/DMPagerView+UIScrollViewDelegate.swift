//
//  DMPagerView+UIScrollViewDelegate.swift
//  DMPagerView
//
//  Created by Dominic Miller on 9/7/18.
//  Copyright © 2018 Dominic Miller. All rights reserved.
//

import UIKit

/// Implementation of all `UIScrollViewDelegate` methods.
/// Each method will call itself on the delegate, if it has been implemented.
public extension DMPagerView {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let selector = #selector(UIScrollViewDelegate.scrollViewDidScroll(_:))
        if objectRespondsToSelector(delegate, selector: selector) {
            delegate!.scrollViewDidScroll!(scrollView)
        }
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let selector = #selector(UIScrollViewDelegate.scrollViewDidZoom(_:))
        if objectRespondsToSelector(delegate, selector: selector) {
            delegate!.scrollViewDidZoom!(scrollView)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let selector = #selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:))
        if objectRespondsToSelector(delegate, selector: selector) {
            delegate!.scrollViewWillBeginDragging!(scrollView)
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let position  = targetContentOffset.pointee.x
        let width     = scrollView.bounds.width
        
        let index = Int(position / width)
        willMovePage(to: index)
        
        let selector = #selector(UIScrollViewDelegate.scrollViewWillEndDragging(_:withVelocity:targetContentOffset:))
        if objectRespondsToSelector(delegate, selector: selector){
            delegate!.scrollViewWillEndDragging!(scrollView,
                                                 withVelocity: velocity,
                                                 targetContentOffset: targetContentOffset)
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let selector = #selector(UIScrollViewDelegate.scrollViewDidEndDragging(_:willDecelerate:))
        if objectRespondsToSelector(delegate, selector: selector) {
            delegate!.scrollViewDidEndDragging!(scrollView, willDecelerate: decelerate)
        }
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let selector = #selector(UIScrollViewDelegate.scrollViewWillBeginDecelerating(_:))
        if objectRespondsToSelector(delegate, selector: selector) {
            delegate!.scrollViewWillBeginDecelerating!(scrollView)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        self.index = index
        didMovePage(to: index)
        
        let selector = #selector(UIScrollViewDelegate.scrollViewDidEndDecelerating(_:))
        if objectRespondsToSelector(delegate, selector: selector) {
            delegate!.scrollViewDidEndDecelerating!(scrollView)
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        didMovePage(to: index)
        let selector = #selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation(_:))
        if objectRespondsToSelector(delegate, selector: selector) {
            delegate!.scrollViewDidEndScrollingAnimation!(scrollView)
        }
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        let selector = #selector(UIScrollViewDelegate.viewForZooming(in:))
        if objectRespondsToSelector(delegate, selector: selector) {
            return delegate!.viewForZooming!(in: scrollView)
        } else {
            return nil
        }
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        let selector = #selector(UIScrollViewDelegate.scrollViewWillBeginZooming(_:with:))
        if objectRespondsToSelector(delegate, selector: selector) {
            delegate!.scrollViewWillBeginZooming!(scrollView, with: view)
        }
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let selector = #selector(UIScrollViewDelegate.scrollViewDidEndZooming(_:with:atScale:))
        if objectRespondsToSelector(delegate, selector: selector) {
            delegate!.scrollViewDidEndZooming!(scrollView, with: view, atScale: scale)
        }
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        let selector = #selector(UIScrollViewDelegate.scrollViewShouldScrollToTop(_:))
        if objectRespondsToSelector(delegate, selector: selector) {
            return delegate!.scrollViewShouldScrollToTop!(scrollView)
        } else {
            return scrollView.scrollsToTop
        }
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        let selector = #selector(UIScrollViewDelegate.scrollViewDidScrollToTop(_:))
        if objectRespondsToSelector(delegate, selector: selector) {
            delegate!.scrollViewDidScrollToTop!(scrollView)
        }
    }
    
    @available(iOS 11.0, *)
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        let selector = #selector(UIScrollViewDelegate.scrollViewDidChangeAdjustedContentInset(_:))
        if objectRespondsToSelector(delegate, selector: selector) {
            delegate!.scrollViewDidChangeAdjustedContentInset!(scrollView)
        }
    }
    
}

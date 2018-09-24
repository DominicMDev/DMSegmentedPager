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
extension DMPagerView {
    
    @objc open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll?(scrollView)
    }
    
    @objc open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidZoom?(scrollView)
    }
    
    @objc open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    @objc open func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                              withVelocity velocity: CGPoint,
                                              targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let position  = targetContentOffset.pointee.x
        let width     = scrollView.bounds.width
        
        let index = Int(position / width)
        willMovePage(to: index)
        
        delegate?.scrollViewWillEndDragging?(scrollView,
                                             withVelocity: velocity,
                                             targetContentOffset: targetContentOffset)
    }
    
    @objc open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    @objc open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    @objc open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        self.index = index
        didMovePage(to: index)
        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    @objc open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        didMovePage(to: index)
        delegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    @objc open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return delegate?.viewForZooming?(in: scrollView)
    }
    
    @objc open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        delegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    
    @objc open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        delegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    @objc open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return delegate?.scrollViewShouldScrollToTop?(scrollView) ?? scrollView.scrollsToTop
    }
    
    @objc open func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScrollToTop?(scrollView)
    }
    
    @available(iOS 11.0, *)
    @objc open func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
    
}

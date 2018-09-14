//
//  DMSegmentedPager.swift
//  DMSegmentedPager
//
//  Created by Dominic on 9/10/18.
//  Copyright © 2018 DominicMiller. All rights reserved.
//

import UIKit
import DMPagerView
import DMParallaxHeader
import DMSegmentedControl

public enum DMSegmentedControlPosition: Int {
    case top, bottom, topOver
}
public class DMSegmentedPager: UIView, UIScrollViewDelegate, DMPagerViewDelegate, DMPagerViewDataSource {
    
    var _contentView: DMScrollView!
    var _segmentedControl: DMSegmentedControl!
    var _toolbar: UIToolbar!
    var _pager: DMPagerView!
    
    var contentView: DMScrollView {
        if _contentView == nil  {
            _contentView = DMScrollView(frame: .zero)
            _contentView.delegate = self
            addSubview(_contentView)
        }
        return _contentView
    }
    
    public var segmentedControl: DMSegmentedControl {
        if _segmentedControl == nil {
            _segmentedControl = DMSegmentedControl(frame: .zero)
            _segmentedControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
            contentView.addSubview(_segmentedControl)
        }
        return _segmentedControl
    }
    
    public var toolbar: UIToolbar {
        if _toolbar == nil {
            _toolbar = UIToolbar(frame: .zero)
            contentView.addSubview(_toolbar)
        }
        return _toolbar
    }
    
    public var pager: DMPagerView {//TODO: Import and use DMPagerView
        if _pager == nil {
            _pager = DMPagerView(frame: frame)
            _pager.delegate = self
            _pager.dataSource = self
            contentView.addSubview(_pager)
        }
        return _pager
    }
    
    var selectedPage: UIView? {
        return pager.selectedPage
    }
    
    public var bouces: Bool {
        get { return contentView.bounces }
        set { contentView.bounces = newValue }
    }
    
    public var parallaxHeader: DMParallaxHeader {
        return contentView.parallaxHeader
    }
    
    @IBOutlet public weak var delegate: DMSegmentedPagerDelegate?
    @IBOutlet public weak var dataSource: DMSegmentedPagerDataSource?
    
    var count: Int = 0
    var index: Int = 0
    var pages = [Int:UIView]()
    
    var controlHeight: CGFloat = 44
    var toolbarHeight: CGFloat = 0
    
    public var segmentedControlPosition: DMSegmentedControlPosition = .top {
        didSet { setNeedsLayout() }
    }
    
    public var segmentedControlEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet { setNeedsLayout() }
    }
    
    /*
     * MARK: - Layout
     */
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if count <= 0 { reloadData() }
        layoutContentView()
        layoutSegmentedControl()
        layoutToolbar()
        layoutPager()
    }
    
    private func layoutContentView() {
        var frame = bounds
        frame.origin = .zero
        self.contentView.frame = frame
        contentView.contentSize = contentView.frame.size
        contentView.isScrollEnabled = contentView.parallaxHeader.view != nil
        contentView.contentInset = UIEdgeInsets(top: contentView.parallaxHeader.height, left: 0, bottom: 0, right: 0)
    }
    
    private func layoutSegmentedControl() {
        var frame = bounds
        frame.origin.x = segmentedControlEdgeInsets.left
        
        switch segmentedControlPosition {
        case .bottom:
            frame.origin.y  = frame.size.height
            frame.origin.y -= controlHeight
            frame.origin.y -= segmentedControlEdgeInsets.bottom
            
        case .topOver:
            frame.origin.y = -controlHeight
            
        case .top:
            frame.origin.y = segmentedControlEdgeInsets.top
        }
        
        frame.size.width -= segmentedControlEdgeInsets.left
        frame.size.width -= segmentedControlEdgeInsets.right
        frame.size.height = controlHeight
        segmentedControl.frame = frame
    }
    
    private func layoutToolbar() {
        var frame = bounds
        frame.origin = .zero
        frame.origin.y  = controlHeight
        frame.origin.y += segmentedControlEdgeInsets.top
        frame.origin.y += segmentedControlEdgeInsets.bottom
        frame.size.height = toolbarHeight
        toolbar.frame = frame
    }
    
    private func layoutPager() {
        var frame = bounds
        frame.origin = .zero
        switch segmentedControlPosition {
        case .top:
            frame.origin.y  = controlHeight + toolbarHeight
            frame.origin.y += segmentedControlEdgeInsets.top
            frame.origin.y += segmentedControlEdgeInsets.bottom
            fallthrough
        case .bottom:
            frame.size.height -= controlHeight + toolbarHeight
            frame.size.height -= segmentedControlEdgeInsets.top
            frame.size.height -= segmentedControlEdgeInsets.bottom
        case .topOver:
            break
        }
        frame.size.height -= contentView.parallaxHeader.minimumHeight
        pager.frame = frame
        
    }
    
    public func reloadData() {
        guard let dataSource = dataSource, let delegate = delegate else { return }
        count = dataSource.numberOfPages(in: self)
        assert(count > 0, "Number of pages in ZRSegmentedPager must be greater than 0")
        
        controlHeight = 44
        if delegate.responds(to: #selector(DMSegmentedPagerDelegate.heightForSegmentedControlInSegmentedPager(_:))) {
            controlHeight = delegate.heightForSegmentedControlInSegmentedPager!(self)
        }
        
        var images = [UIImage]()
        var selectedImages = [UIImage]()
        var titles = [String]()
        
        for index in 0..<count {
            
            var title = "Page \(index)"
            if dataSource.responds(to: #selector(DMSegmentedPagerDataSource.segmentedPager(_:titleForSectionAt:))) {
                title = dataSource.segmentedPager!(self, titleForSectionAt: index)
            }
            titles.insert(title, at: index)
            
            if dataSource.responds(to: #selector(DMSegmentedPagerDataSource.segmentedPager(_:imageForSectionAt:))) {
                images.insert(dataSource.segmentedPager!(self, imageForSectionAt: index), at: index)
            }
            
            if dataSource.responds(to: #selector(DMSegmentedPagerDataSource.segmentedPager(_:selectedImageForSectionAt:))) {
                selectedImages.insert(dataSource.segmentedPager!(self, selectedImageForSectionAt: index), at: index)
            }
            
        }
        
        if dataSource.responds(to: #selector(DMSegmentedPagerDataSource.segmentedPager(_:attributedTitleForSectionAt:))) {
            segmentedControl.titleFormatter = { [weak self] (segmentedControl, title, index, selected) in
                guard let _self = self else { return NSAttributedString(string: "") }
                return _self.dataSource!.segmentedPager!(_self, attributedTitleForSectionAt: index)
            }
        }
        
        segmentedControl.sectionImages = images
        segmentedControl.sectionSelectedImages = selectedImages
        segmentedControl.sectionTitles = titles
        segmentedControl.setNeedsDisplay()
        
        pager.reloadData()
    }
    
    public func scrollToTop(animated: Bool = false) {
        contentView.setContentOffset(CGPoint(x: 0, y: -contentView.parallaxHeader.height), animated: animated)
    }
    
    @objc func pageControlValueChanged(_ segmentedControl: DMSegmentedControl) {
        pager.showPage(at: segmentedControl.selectedSegmentIndex, animated: true)
    }
    
    public func setToolBarHeight(_ height: CGFloat) {
        if (height > toolbarHeight) {
            toolbarHeight = height
            layoutToolbar()
            layoutPager()
        } else if (height < toolbarHeight) {
            toolbarHeight = height
            layoutPager()
            layoutToolbar()
        }
    }

}

/*
 * MARK: - Delegates
 */

public extension DMSegmentedPager {
    
    // MARK: - DMPagerViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === contentView, let delegate = delegate,
            delegate.responds(to: #selector(DMSegmentedPagerDelegate.segmentedPager(_:didScrollWith:))) {
            delegate.segmentedPager!(self, didScrollWith: scrollView.parallaxHeader)
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView === contentView, let delegate = delegate,
            delegate.responds(to: #selector(DMSegmentedPagerDelegate.segmentedPager(_:didEndDraggingWith:))) {
            delegate.segmentedPager!(self, didEndDraggingWith: scrollView.parallaxHeader)
        }
    }
    
    public func scrollView(_ scrollView: DMScrollView, shouldScrollWithSubView subView: UIScrollView) -> Bool {
        if subView === pager { return false }
        guard let page = pager.selectedPage as? DMPageProtocol,
            page.responds(to: #selector(DMPageProtocol.segmentedPager(_:shouldScrollWith:))) else { return true }
        return page.segmentedPager!(self, shouldScrollWith: subView)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if let delegate = delegate,
            delegate.responds(to: #selector(DMSegmentedPagerDelegate.segmentedPagerShouldScrollToTop(_:))) {
            return delegate.segmentedPagerShouldScrollToTop!(self)
        }
        return true
    }
    
    // MARK: - DMPagerViewDelegate
    
    public func pagerView(_ pagerView: DMPagerView, willMoveToPage page: UIView, at index: Int) {
        segmentedControl.setSelectedSegmentIndex(index, animated: true)
        if let delegate = delegate,
            delegate.responds(to: #selector(DMSegmentedPagerDelegate.segmentedPager(_:willMoveToPage:at:))) {
            delegate.segmentedPager!(self, willMoveToPage: page, at: index)
        }
    }
    
    public func pagerView(_ pagerView: DMPagerView, didMoveToPage page: UIView, at index: Int) {
        segmentedControl.setSelectedSegmentIndex(index, animated: false)
        changedToIndex(index)
        if let delegate = delegate,
            delegate.responds(to: #selector(DMSegmentedPagerDelegate.segmentedPager(_:didMoveToPage:at:))) {
            delegate.segmentedPager!(self, didMoveToPage: page, at: index)
        }
    }
    
    private func changedToIndex(_ index: Int) {
        guard let delegate = delegate else { return }
        if delegate.responds(to: #selector(DMSegmentedPagerDelegate.segmentedPager(_:didSelectPageAt:))) {
            delegate.segmentedPager!(self, didSelectPageAt: index)
        }
        
        let title = segmentedControl.sectionTitles[index]
        
        if delegate.responds(to: #selector(DMSegmentedPagerDelegate.segmentedPager(_:didSelectPageWith:))) {
            delegate.segmentedPager!(self, didSelectPageWith: title)
        }
        
        if let view = pager.selectedPage,
            delegate.responds(to: #selector(DMSegmentedPagerDelegate.segmentedPager(_:didSelectPage:))) {
            delegate.segmentedPager!(self, didSelectPage: view)
        }
    }
    
    public func pagerView(_ pagerView: DMPagerView, willDisplayPage page: UIView, at index: Int) {
        if let delegate = delegate,
            delegate.responds(to: #selector(DMSegmentedPagerDelegate.segmentedPager(_:willDisplayPage:at:))) {
            delegate.segmentedPager!(self, willDisplayPage: page, at: index)
        }
    }
    
    public func pagerView(_ pagerView: DMPagerView, didEndDisplayingPage page: UIView, at index: Int) {
        if let delegate = delegate,
            delegate.responds(to: #selector(DMSegmentedPagerDelegate.segmentedPager(_:didEndDisplayingPage:at:))) {
            delegate.segmentedPager!(self, didEndDisplayingPage: page, at: index)
        }
    }
    
    // MARK: - DMPagerViewDataSource
    
    public func numberOfPages(in pagerView: DMPagerView) -> Int {
        return count
    }
    
    public func pagerView(_ pagerView: DMPagerView, viewForPageAt index: Int) -> UIView {
        return dataSource?.segmentedPager(self, viewForPageAt: index) ?? UIView(frame: .zero)
    }
    
}

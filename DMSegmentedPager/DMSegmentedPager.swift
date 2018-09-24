//
//  DMSegmentedPager.swift
//  DMSegmentedPager
//
//  Created by Dominic on 9/10/18.
//  Copyright © 2018 DominicMiller. All rights reserved.
//

import UIKit
@_exported import DMPagerView
@_exported import DMParallaxHeader
@_exported import DMSegmentedControl

public enum DMSegmentedControlPosition: Int {
    case top, bottom, topOver
}

open class DMSegmentedPager: UIView, DMScrollViewDelegate, DMPagerViewDelegate, DMPagerViewDataSource {
    
    var _contentView: DMScrollView!
    var _segmentedControl: DMSegmentedControl!
    var _toolbar: UIToolbar!
    var _pager: DMPagerView!
    
    public var contentView: DMScrollView {
        if _contentView == nil  {
            _contentView = DMScrollView(frame: .zero)
            _contentView.delegate = self
            addSubview(_contentView)
        }
        return _contentView
    }
    
    public var segmentedControl: DMSegmentedControl {
        if _segmentedControl == nil {
            _ = pager
            _segmentedControl = DMSegmentedControl(frame: .zero)
            _segmentedControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
            contentView.addSubview(_segmentedControl)
        }
        return _segmentedControl
    }
    
    public var toolbar: UIToolbar {
        if _toolbar == nil {
            _ = segmentedControl
            _toolbar = UIToolbar(frame: .zero)
            contentView.addSubview(_toolbar)
        }
        return _toolbar
    }
    
    public var pager: DMPagerView {
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
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if count <= 0 { reloadData() }
        layoutContentView()
        layoutSegmentedControl()
        layoutToolbar()
        layoutPager()
    }
    
    private func layoutContentView() {
        let isAtTop = _contentView != nil && contentView.contentOffset.y == 0
        
        var frame = bounds
        frame.origin = .zero
        self.contentView.frame = frame
        contentView.contentSize = contentView.frame.size
        contentView.isScrollEnabled = contentView.parallaxHeader.view != nil
        contentView.contentInset = UIEdgeInsets(top: contentView.parallaxHeader.height, left: 0, bottom: 0, right: 0)
        
        if isAtTop {
            contentView.setContentOffset(.zero, animated: false)
        }
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
        guard let dataSource = dataSource else { return }
        count = dataSource.numberOfPages(in: self)
        assert(count > 0, "Number of pages in DMSegmentedPager must be greater than 0")
        
        controlHeight = delegate?.heightForSegmentedControlInSegmentedPager?(self) ?? 44
        
        var images = [UIImage]()
        var selectedImages = [UIImage]()
        var titles = [String]()
        
        for index in 0..<count {
            let title = dataSource.segmentedPager?(self, titleForSectionAt: index) ?? "Page \(index)"
            titles.insert(title, at: index)
            if let image = dataSource.segmentedPager?(self, imageForSectionAt: index) {
                images.insert(image, at: index)
            }
            if let selectedImage = dataSource.segmentedPager?(self, selectedImageForSectionAt: index) {
                selectedImages.insert(selectedImage, at: index)
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
    
    public func scrollToBottom(animated: Bool = true) {
        let bottom = contentView.contentSize.height - contentView.bounds.size.height
        contentView.setContentOffset(CGPoint(x: 0, y: bottom), animated: animated)
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

extension DMSegmentedPager {
    
    // MARK: - DMPagerViewDelegate
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
         guard scrollView === contentView else { return }
            delegate?.segmentedPager?(self, didScrollWith: scrollView.parallaxHeader)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView === contentView else { return }
        delegate?.segmentedPager?(self, didEndDraggingWith: scrollView.parallaxHeader)
    }
    
    open func scrollView(_ scrollView: DMScrollView, shouldScrollWithSubView subView: UIScrollView) -> Bool {
        if subView === pager { return false }
        if subView === pager.scrollView { return false }
        guard let page = selectedPage as? DMPageProtocol else { return true }
        return page.segmentedPager?(self, shouldScrollWith: subView) ?? true
    }
    
    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return delegate?.segmentedPagerShouldScrollToTop?(self) ?? scrollView.scrollsToTop
    }
    
    // MARK: - DMPagerViewDelegate
    
    open func pagerView(_ pagerView: DMPagerView, willMoveToPage page: UIView, at index: Int) {
        segmentedControl.setSelectedSegmentIndex(index, animated: true)
        delegate?.segmentedPager?(self, willMoveToPage: page, at: index)
    }
    
    open func pagerView(_ pagerView: DMPagerView, didMoveToPage page: UIView, at index: Int) {
        segmentedControl.setSelectedSegmentIndex(index, animated: false)
        changedToIndex(index)
        delegate?.segmentedPager?(self, didMoveToPage: page, at: index)
    }
    
    private func changedToIndex(_ index: Int) {
        delegate?.segmentedPager?(self, didSelectPageAt: index)
        delegate?.segmentedPager?(self, didSelectPageWith: segmentedControl.sectionTitles[index])
        
        guard let view = selectedPage else { return }
        delegate?.segmentedPager?(self, didSelectPage: view)
    }
    
    open func pagerView(_ pagerView: DMPagerView, willDisplayPage page: UIView, at index: Int) {
        delegate?.segmentedPager?(self, willDisplayPage: page, at: index)
    }
    
    open func pagerView(_ pagerView: DMPagerView, didEndDisplayingPage page: UIView, at index: Int) {
        delegate?.segmentedPager?(self, didEndDisplayingPage: page, at: index)
    }
    
    // MARK: - DMPagerViewDataSource
    
    open func numberOfPages(in pagerView: DMPagerView) -> Int {
        return count
    }
    
    open func pagerView(_ pagerView: DMPagerView, viewForPageAt index: Int) -> UIView {
        return dataSource?.segmentedPager(self, viewForPageAt: index) ?? UIView(frame: .zero)
    }
    
}

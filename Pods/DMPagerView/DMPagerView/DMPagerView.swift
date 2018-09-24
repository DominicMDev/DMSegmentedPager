//
//  DMPagerView.swift
//  DMPagerView
//
//  Created by Dominic Miller on 9/6/18.
//  Copyright © 2018 Dominic Miller. All rights reserved.
//

import UIKit
import ObjectiveC

/// A DMPagerView lets the user navigate between pages of content.
/// Navigation can be controlled programmatically by your app or directly by the user using gestures.
open class DMPagerView: UIView, UIScrollViewDelegate {
    
    /*
     *  MARK: - Instance Properties - Internal
     */
    
    public internal(set) var scrollView: UIScrollView
    
    var pages = [Int : UIView]()
    
    var registration = [String:Any]()
    var reuseQueue = [UIView]()
    
    var index: Int = 0
    var count: Int = 0
    
    // MARK: - Instance Properties - Public
    
    /// Delegate instance that adopt the `DMPagerViewDelegate`.
    @IBOutlet public dynamic weak var delegate: DMPagerViewDelegate?

    /// Data source instance that adopt the DMPagerViewDataSource.
    @IBOutlet public weak var dataSource: DMPagerViewDataSource?
    
    /// The pager transition style.
    public var transitionStyle: DMPagerViewTransitionStyle = .scroll {
        didSet { scrollView.isScrollEnabled = (transitionStyle != .tab) }
    }
    
    /// The gutter width. 0 by default.
    public var gutterWidth: CGFloat = 0 {
        didSet { setNeedsLayout(); scrollView.setNeedsLayout() }
    }
    
    // MARK: Computed Properties
    
    /// The current selected page view.
    public var selectedPage: UIView? {
        return page(at: index)
    }
    
    /// The index representing page of selection.
    public var indexForSelectedPage: Int {
        return index
    }
    
    /// The pager progress, from 0 to the number of page.
    public var progress: CGFloat {
        let position = scrollView.contentOffset.x
        let width = bounds.width
        if width == 0 { return 0 }
        return position / width
    }
    
    /*
     *  MARK: - Object Life Cycle
     */
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    override public init(frame: CGRect) {
        scrollView = UIScrollView(frame: frame)
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        scrollView = UIScrollView(frame: .zero)
        super.init(coder: aDecoder)
        scrollView.frame = frame
        initialize()
    }

    private func initialize() {
        addScrollView()
        isUserInteractionEnabled = true
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.scrollsToTop = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    private func addScrollView() {
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     scrollView.topAnchor.constraint(equalTo: topAnchor),
                                     scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    
    /*
     *  MARK: - View Life Cycle
     */
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if count <= 0 { reloadData() }
        
        var size = bounds.size
        size.width = size.width * CGFloat(count)
        
        if !size.equalTo(scrollView.contentSize) {
            scrollView.contentSize = size
            
            let x = bounds.size.width * CGFloat(index)
            scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
            
            layoutLoadedPages()
        }
    }
    
    private func layoutLoadedPages() {
        var frame: CGRect = .zero
        frame.size = bounds.size
        for (index, page) in pages {
            frame.origin.x = frame.size.width * CGFloat(index)
            page.frame = frame
        }
    }
    
    /// Reloads everything from scratch. redisplays pages.
    public func reloadData() {
        for (_, page) in pages { page.removeFromSuperview() }
        pages.removeAll()
        
        count = dataSource?.numberOfPages(in: self) ?? 0
        if count > 0 {
            index = min(index, count - 1)
            loadPage(at: index)
            setNeedsLayout()
        }
    }
    
    /// Shows through the pager until a page identified by index is at a particular location on the screen.
    ///
    /// - Parameters:
    ///   - index: An index that identifies a page.
    ///   - animated: A flag indicating whether or not you want to animate the change in position.
    ///
    /// - Note: The `animated` parameter has no effect on pager with `transitionStyle` of `.tab`.
    public func showPage(at index: Int, animated: Bool) {
        var animated = animated
        guard index >= 0 && index < count && index != self.index else { return }
        self.index = index
        
        if transitionStyle == .tab { animated = false }
        
        let x = bounds.size.width * CGFloat(index)
        setContentOffset(CGPoint(x: x, y: 0), animated: animated)
    }
    
    /// Gets a page at specific index.
    ///
    /// - Parameter index: Index representing page
    /// - Returns: The page at a given index. If the page is not loaded or `index` is out of range, returns `nil`
    public func page(at index: Int) -> UIView? {
        return pages[index]
    }
    
    // MARK: - Reusable Pages
    
    /// Registers a nib object containing a page with the pager view under a specified identifier.
    ///
    /// Before dequeueing any pages, call this method or the ```registerClass:forPageReuseIdentifier:```
    /// method to tell the pager view how to create new pages. If a page of the specified type is not currently in a
    /// reuse queue, the pager view uses the provided information to create a new page object automatically.
    ///
    /// If you previously registered a class or nib file with the same reuse identifier, the nib you specify in the
    /// `nib` parameter replaces the old entry. You may specify nil for nib if you want to unregister the nib from the
    /// specified reuse identifier.
    ///
    /// - Parameters:
    ///   - nib: A nib object that specifies the nib file to use to create the page.
    ///   - identifier: The reuse identifier for the page. This parameter must not be an empty string.
    public func register(_ nib: UINib, forPageReuseIdentifier identifier: String) {
        guard !identifier.isEmpty else { return }
        registration[identifier] = nib
    }
    
    /// Registers a class for use in creating new page.
    ///
    /// Prior to dequeueing any pages, call this method or the `registerNib:forPageReuseIdentifier:` method to tell the
    /// pager view how to create new pages. If a page of the specified type is not currently in a reuse queue, the pager
    /// view uses the provided information to create a new page object automatically.
    ///
    /// If you previously registered a class or nib file with the same reuse identifier, the class you specify in the
    /// pageClass parameter replaces the old entry. You may specify nil for pageClass if you want to unregister the
    /// class from the specified reuse identifier.
    ///
    /// - Parameters:
    ///   - pageClass: The class of a page that you want to use in the pager.
    ///   - identifier: The reuse identifier for the page. This parameter must not be an empty string.
    public func register(_ pageClass: AnyClass, forPageReuseIdentifier identifier: String) {
        guard !identifier.isEmpty else { return }
        registration[identifier] = NSStringFromClass(pageClass)
    }
    
    /// Returns a reusable page object located by its identifier.
    ///
    /// A pager view maintains a queue or list of page objects that the data source has marked for reuse. Call this
    /// method from your data source object when asked to provide a new page for the pager view. This method dequeues an
    /// existing page if one is available or creates a new one using the class or nib file you previously registered.
    /// If no page is available for reuse and you did not register a class or nib file, this method returns nil.
    ///
    /// - Parameter identifier: A string identifying the page object to be reused. This parameter must not be nil
    /// - Returns: A page object with the associated identifier. If no such object exists in the queue, returns nil.
    public func dequeueReusablePage(withIdentifier identifier: String) -> UIView? {
        if let page = dequeueFromReuseQueue(with: identifier) {
            return page
        }
        if let page = dequeueFromRegistration(with: identifier) {
            objc_setAssociatedObject(page, UIView.Keys.ReuseIdentifier, identifier, .OBJC_ASSOCIATION_COPY)
            return page
        }
        return nil
    }
    
    private func dequeueFromReuseQueue(with identifier: String) -> UIView? {
        for (idx, reuse) in reuseQueue.enumerated() {
            guard reuse.reuseIdentifier == identifier else { continue }
            reuseQueue.remove(at: idx)
            reuse.prepareForReuse()
            return reuse
        }
        return nil
    }
    
    private func dequeueFromRegistration(with identifier: String) -> UIView? {
        let builder = registration[identifier]
        let message = "Unable to dequeue a page with identifier \(identifier) - must register a nib or a class."
        assert(builder != nil, message)
        
        if let builder = builder as? UINib {
            return builder.instantiate(withOwner: nil, options: nil).first as? UIView
        }
        if let builder = builder as? String {
            return (NSClassFromString(builder) as? UIView.Type)?.init()
        }
        return nil
    }
    
    /*
     *  MARK: - Internal Methods
     */
    
    internal func willMovePage(to index: Int) {
        loadPage(at: index)
        let page = pages[index]!
        delegate?.pagerView?(self, willMoveToPage: page, at: index)
    }
    
    internal func didMovePage(to index: Int) {
        defer { unloadHiddenPages() }
        guard let page = pages[index] else { return }
        delegate?.pagerView?(self, didMoveToPage: page, at: index)
    }
    
    private func loadPage(at index: Int) {
        guard let dataSource = dataSource, index >= 0 && index < count else { return }
        if page(at: index) == nil {
            let page = dataSource.pagerView(self, viewForPageAt: index)
            
            //Layout page
            var frame: CGRect = .zero
            frame.size = bounds.size
            frame.origin = CGPoint(x: frame.width * CGFloat(index), y: 0)
            page.frame = frame
            
            delegate?.pagerView?(self, willDisplayPage: page, at: index)
            
            scrollView.addSubview(page)
            scrollView.setNeedsLayout()
            setNeedsLayout()
            
            //Save page
            pages[index] = page
            
        }
        //In  case of slide behavior, its loads the neighbors as well.
        if transitionStyle == .scroll {
            if page(at: index - 1) == nil { loadPage(at: index - 1) }
            if page(at: index + 1) == nil { loadPage(at: index + 1) }
        }
    }
            
    private func unloadHiddenPages() {
        var toUnload = [Int]()
        
        for (index, page) in pages {
            guard index != self.index else { continue }
            //In case if slide behavior, it keeps the neighbors, otherwise it unloads all hidden pages.
            if transitionStyle == .tab || (index != self.index - 1 && index != self.index + 1) {
                page.removeFromSuperview()
                toUnload.append(index)
                
                if page.reuseIdentifier != nil { reuseQueue.append(page) }
                delegate?.pagerView?(self, didEndDisplayingPage: page, at: index)
            }
        }
        pages.removeValues(forKeys: toUnload)
    }
    
    
    /// Sets the offset from the content view’s origin that corresponds to the receiver’s origin.
    ///
    /// - Parameters:
    ///   - contentOffset: A point (expressed in points) that is offset from the content view’s origin.
    ///   - animated: true to animate the transition at a constant velocity to the new offset, false to make the transition immediate.
    public func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        if fmod(contentOffset.x, bounds.width) == 0 {
            let index = Int(contentOffset.x / bounds.width)
            
            willMovePage(to: index)
            scrollView.setContentOffset(contentOffset, animated: animated)
            
            self.index = index
            
            if !animated { didMovePage(to: index) }
            
        } else {
            scrollView.setContentOffset(contentOffset, animated: animated)
        }
    }

}

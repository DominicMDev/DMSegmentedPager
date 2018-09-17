//
//  DMSegmentedControl.swift
//  DMSegmentedControl
//
//  Created by Dominic on 9/5/18.
//  Copyright © 2018 DominicMiller. All rights reserved.
//

import UIKit
import QuartzCore

class ScrollView: UIScrollView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDragging {
            next?.touchesBegan(touches, with: event)
        } else {
            super.touchesBegan(touches, with: event)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDragging {
            next?.touchesMoved(touches, with: event)
        } else {
            super.touchesMoved(touches, with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDragging {
            next?.touchesEnded(touches, with: event)
        } else {
            super.touchesEnded(touches, with: event)
        }
    }
    
}

public typealias SelectedIndexTappedBlock = (() -> Void)
public typealias IndexChangeBlock = ((_ index: Int) -> Void)
public typealias DMTitleFormatterBlock = ((_ segmentedControl: DMSegmentedControl, _ title: String, _ index: Int, _ selected: Bool) -> NSAttributedString)

open class DMSegmentedControl: UIControl {
    
    private var selectionIndicatorStripLayer: CALayer!
    private var selectionIndicatorBoxLayer: CALayer!
    private var selectionIndicatorArrowLayer: CALayer!
    private var segmentWidth: CGFloat = 0
    private var segmentWidthsArray = [CGFloat]()
    private var scrollView: ScrollView = ScrollView()
    private var touchesMoved: Bool = false
    
    public var sectionTitles = [String]() {
        didSet {
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
    }
    
    public var sectionImages = [UIImage]() {
        didSet {
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
    }
    
    public var sectionSelectedImages = [UIImage]()
    
    /// Provide a block to be executed when index is tapped while already selected.
    public var selectedIndexTappedBlock: SelectedIndexTappedBlock = {}
    
    /// Provide a block to be executed when selected index is changed.
    /// Alternativly, you could use `addTarget:action:forControlEvents:`
    public var indexChangeBlock: IndexChangeBlock? = nil
    
    /// Used to apply custom text styling to titles when set. When this block is set,
    /// no additional styling is applied to the `NSAttributedString` object returned from this block.
    public var titleFormatter: DMTitleFormatterBlock? = nil
    
    /// Text attributes to apply to item title text.
    @objc public dynamic var titleTextAttributes = [NSAttributedStringKey : Any]()
    
    /// Text attributes to apply to selected item title text.
    /// Attributes not set in this dictionary are inherited from `titleTextAttributes`.
    @objc public dynamic var selectedTitleTextAttributes = [NSAttributedStringKey : Any]()
    
    /// Color for the selection indicator stripe. Default is `red:0.204, green:0.710, blue:0.898`
    @objc public dynamic var selectionIndicatorColor: UIColor = UIColor(red: 0.204, green: 0.710, blue: 0.898, alpha: 1)
    
    /// Color for the selection indicator box. Default is `red:0.204, green:0.710, blue:0.898`
    @objc public dynamic var selectionIndicatorBoxColor: UIColor = UIColor(red: 0.204, green: 0.710, blue: 0.898, alpha: 1)
    
    /// Color for the vertical divider between segments. Default is `.black`
    @objc public dynamic var verticalDividerColor: UIColor = .black
    
    /// Opacity for the seletion indicator box. Default is `0.2`
    public var selectionIndicatorBoxOpacity: CGFloat = 0.2 {
        didSet {
            self.selectionIndicatorBoxLayer?.opacity = Float(selectionIndicatorBoxOpacity)
        }
    }
    
    /// The width of the vertical divider between segments that is added when `isVerticalDividerEnabled` is set to true.
    /// Default is `1.0`
    public var verticalDividerWidth: CGFloat = 1.0
    
    /// Specifies the style of the control. Default is `.text`
    public var type: DMSegmentedControlType = .text {
        didSet {
            if type == .images { segmentWidthStyle = .fixed }
        }
    }
    
    /// Specifies the style of the selection indicator. Default is `.textWidthStripe`
    public var selectionStyle: DMSegmentedControlSelectionStyle = .textWidthStripe
    
    /// Specifies the style of the segment's width. Default is `.dynamic`
    ///
    /// - Note: Forces to `.fixed` when `self.type` is `.images`.
    public var segmentWidthStyle: DMSegmentedControlSegmentWidthStyle = .dynamic {
        didSet {
            if self.type == .images { segmentWidthStyle = .fixed }
        }
    }
    
    /// Specifies the location of the selection indicator. Default is `.down`
    public var selectionIndicatorLocation: DMSegmentedControlSelectionIndicatorLocation = .down {
        didSet {
            if selectionIndicatorLocation == .none { selectionIndicatorHeight = 0.0 }
        }
    }
    
    /// Specifies the border type. Default is `.none`.
    public var borderType: DMSegmentedControlBorderType = .none {
        didSet { self.setNeedsDisplay() }
    }
    
    /// Specifies the image position relative to the text. Only applicable when `self.type` is `.textImages`.
    /// Default is `.behindText`
    public var imagePosition: DMSegmentedControlImagePosition = .behindText
    
    /// Specifies the distance between the text and the image. Only applicable when `self.type` is `.textImages`.
    /// Default is `0.0`
    public var textImageSpacing: CGFloat = 0
    
    /// Specifies the border color. Default is `.black`
    public var borderColor: UIColor = .black
    
    /// Specifies the border width. Default is `1.0`
    public var borderWidth: CGFloat = 1.0
    
    /// Default is `true`. Set to `false` to deny scrolling by the user dragging the scrollView.
    public var isUserDraggable: Bool = true
    
    /// Default is `true`. Set to `false` to deny any touch events by the user.
    public var isTouchEnabled: Bool = true
    
    /// Default is `false`. Set to `true` to show a vertical divider between the segments.
    public var isVerticalDividerEnabled: Bool = false
    
    public var cancelTouchesOnMovement: Bool = false
    
    public var shouldStretchSegmentsToScreenSize: Bool = true
    
    /// Index of the currently selected segment.
    public var selectedSegmentIndex: Int = 0
    
    /// Height of the selection indicator. Only effective when `self.selectionStyle` is
    /// either `.textWidthStripe` or `.fullWidthStripe`. Default is 2.0
    public var selectionIndicatorHeight: CGFloat = 2.0
    
    /// Edge insets for the selection indicator.
    ///
    /// - NOTE: This does not affect the bounding box of `self.selectionStyle == .box`
    /// When 'self.selectionIndicatorLocation` is:
    /// `.up` - bottom edge insets are not used.
    /// `.down` - top edge insets are not used.
    ///
    ///Default is (0, 0, 0, 0)
    public var selectionIndicatorEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    /// Inset left and right edges of segments. Default is (0, 5, 0, 5)
    public var segmentEdgeInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    public var enlargeEdgeInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    /// Default is `true`. Set to `false` to disable animation during user selection.
    public var shouldAnimateUserSelection: Bool = true
    
    /*
     * MARK: - Object Life Cycle
     */
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public init(sectionImages: [UIImage] = [], sectionSelectedImages: [UIImage] = [], sectionTitles: [String] = []) {
        super.init(frame: .zero)
        commonInit()
        self.sectionImages = sectionImages
        self.sectionSelectedImages = sectionSelectedImages
        self.sectionTitles = sectionTitles
        
        switch (sectionImages.isEmpty, sectionTitles.isEmpty) {
        case (true, true): break
        case (true, false): self.type = .text
        case (false, true): self.type = .images
        case (false, false):
            if sectionImages.count < sectionTitles.count { self.type = .text }
            if sectionImages.count > sectionTitles.count { self.type = .images }
            if sectionImages.count == sectionTitles.count { self.type = .textImages }
        }
    }
    
    private func commonInit() {
        self.scrollView = ScrollView()
        self.scrollView.scrollsToTop = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        
        self.backgroundColor = .white
        self.isOpaque = false
        
        self.selectionIndicatorArrowLayer = CALayer(layer: layer)
        self.selectionIndicatorStripLayer = CALayer(layer: layer)
        self.selectionIndicatorBoxLayer = CALayer(layer: layer)
        self.selectionIndicatorBoxLayer.opacity = Float(self.selectionIndicatorBoxOpacity)
        self.selectionIndicatorBoxLayer.borderWidth = 1.0
        self.selectionIndicatorBoxOpacity = 0.2
        
        self.contentMode = .redraw
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.segmentWidth = 0.0
    }
    
    
    /*
     * MARK: - View Life Cycle
     */
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        updateSegmentsRects()
    }
    
    override open var frame: CGRect {
        didSet {
            updateSegmentsRects()
        }
    }
    
    // MARK: - Drawing
    
    func measureTitle(at index: Int) -> CGSize {
        if index >= sectionTitles.count { return .zero }
        
        let title = self.sectionTitles[index]
        var size = CGSize.zero
        let selected = (index == self.selectedSegmentIndex)
        if self.titleFormatter == nil {
            var titleAttrs = selected ? resultingSelectedTitleTextAttributes : resultingTitleTextAttributes
            size = title.size(withAttributes: titleAttrs)
            let font = titleAttrs[.font] as! UIFont
            size = CGSize(width: ceil(size.width), height: ceil(size.height-font.descender))
        } else if let titleFormatter = self.titleFormatter {
            size = titleFormatter(self, title, index, selected).size()
        }
        
        return CGRect(origin: .zero, size: size).integral.size
    }
    
    func attributedTitle(at index: Int) -> NSAttributedString {
        let title = index >= sectionTitles.count ? "" : self.sectionTitles[index]
        let selected = (index == self.selectedSegmentIndex)
        
        if let titleFormatter = self.titleFormatter {
            return titleFormatter(self, title, index, selected)
        } else {
            let titleAttrs = selected ? resultingSelectedTitleTextAttributes : resultingTitleTextAttributes
            return NSAttributedString(string: title, attributes: titleAttrs)
        }
    }
    
    override open func draw(_ rect: CGRect) {
        backgroundColor?.setFill()
        UIRectFill(bounds)
        
        selectionIndicatorArrowLayer.backgroundColor = selectionIndicatorColor.cgColor
        selectionIndicatorStripLayer.backgroundColor = selectionIndicatorColor.cgColor
        selectionIndicatorBoxLayer.backgroundColor = selectionIndicatorBoxColor.cgColor
        selectionIndicatorBoxLayer.borderColor = selectionIndicatorBoxColor.cgColor
        
        scrollView.layer.sublayers = nil
        let oldRect = rect
        
        switch type {
        case .text: drawForTextType(oldRect)
        case .images: drawForImageType(oldRect)
        case .textImages: drawForTextImageType(oldRect)
        }
        
        // Add the selection indicators
        if selectedSegmentIndex != DMSegmentedControl.NoSegment {
            if selectionStyle == .arrow {
                if selectionIndicatorArrowLayer.superlayer == nil {
                    setArrowFrame()
                    scrollView.layer.addSublayer(selectionIndicatorArrowLayer)
                }
            } else {
                if selectionIndicatorStripLayer.superlayer == nil {
                    selectionIndicatorStripLayer.frame = frameForSelectionIndicator()
                    scrollView.layer.addSublayer(selectionIndicatorStripLayer)
                    
                    if selectionStyle == .box && selectionIndicatorBoxLayer.superlayer == nil {
                        selectionIndicatorBoxLayer.frame = frameForFillerSelectionIndicator()
                        scrollView.layer.insertSublayer(selectionIndicatorBoxLayer, at: 0)
                    }
                }
            }
        }
    }
    
    private func drawForTextType(_ oldRect: CGRect) {
        for (idx, _) in sectionTitles.enumerated() {
            let size = measureTitle(at: idx)
            var rects: (rect: CGRect, rectDiv: CGRect, fullRect: CGRect)
            
            switch segmentWidthStyle{
            case .fixed : rects = fixedTextRects(for: oldRect, index: idx, size: size)
            case .dynamic: rects = dynamicTextRects(for: oldRect, index: idx, size: size)
            }
            
            let titleLayer = CATextLayer(layer: layer)
            titleLayer.frame = rects.rect
            titleLayer.alignmentMode = kCAAlignmentCenter
            if #available(*, iOS 10.0) {
                titleLayer.truncationMode = kCATruncationEnd
            }
            titleLayer.string = attributedTitle(at: idx)
            titleLayer.contentsScale = UIScreen.main.scale
            scrollView.layer.addSublayer(titleLayer)
            
            // Vertical Divider
            if isVerticalDividerEnabled && idx > 0 {
                let verticalDividerLayer = CALayer(layer: layer)
                verticalDividerLayer.frame = rects.rectDiv
                verticalDividerLayer.backgroundColor = verticalDividerColor.cgColor
                scrollView.layer.addSublayer(verticalDividerLayer)
            }
            addBackgroundAndBorderLayer(rect: rects.fullRect)
        }
    }
    
    private func fixedTextRects(for oldRect: CGRect, index: Int, size: CGSize) -> (rect: CGRect, rectDiv: CGRect, fullRect: CGRect) {
        let locationUp: CGFloat = (selectionIndicatorLocation == .up) ? 1 : 0
        let selectionStyleNotBox: CGFloat = (selectionStyle != .box) ? 1 : 0
        let y: CGFloat = round((frame.height - selectionStyleNotBox * selectionIndicatorHeight) / 2 - size.height / 2 + selectionIndicatorHeight * locationUp)
        
        return (rect: CGRect(x: ceil((segmentWidth * CGFloat(index)) + (segmentWidth - size.width) / 2),
                             y: ceil(y),
                             width: ceil(size.width),
                             height: ceil(size.height)),
                rectDiv: CGRect(x: (segmentWidth * CGFloat(index)) - (verticalDividerWidth / 2),
                                y: selectionIndicatorHeight * 2,
                                width: verticalDividerWidth,
                                height: frame.height - (selectionIndicatorHeight * 4)),
                fullRect: CGRect(x: segmentWidth * CGFloat(index),
                                 y: 0, width: segmentWidth,
                                 height: oldRect.height))
    }
    
    private func dynamicTextRects(for oldRect: CGRect, index: Int, size: CGSize) -> (rect: CGRect, rectDiv: CGRect, fullRect: CGRect) {
        let locationUp: CGFloat = (selectionIndicatorLocation == .up) ? 1 : 0
        let selectionStyleNotBox: CGFloat = (selectionStyle != .box) ? 1 : 0
        let y: CGFloat = round((frame.height - selectionStyleNotBox * selectionIndicatorHeight) / 2 - size.height / 2 + selectionIndicatorHeight * locationUp)
        var xOffset: CGFloat = 0
        var i = 0
        for width in segmentWidthsArray {
            if index == i { break }
            xOffset = xOffset + width
            i += 1
        }
        let widthForIndex: CGFloat = segmentWidthsArray[index]
        return (rect: CGRect(x: ceil(xOffset), y: ceil(y), width: ceil(widthForIndex), height: ceil(size.height)),
                rectDiv: CGRect(x: xOffset - (verticalDividerWidth / 2),
                                y: selectionIndicatorHeight * 2,
                                width: verticalDividerWidth,
                                height: frame.size.height - (selectionIndicatorHeight * 4)),
                fullRect: CGRect(x: segmentWidth * CGFloat(index), y: 0,
                                 width: widthForIndex, height: oldRect.size.height))
    }
    
    private func drawForImageType(_ oldRect: CGRect) {
        for (idx, iconImage) in sectionImages.enumerated() {
            let icon = iconImage
            let imageWidth = icon.size.width
            let imageHeight = icon.size.height
            let y = round(frame.height - selectionIndicatorHeight) / 2 - imageHeight / 2 + ((selectionIndicatorLocation == .up) ? selectionIndicatorHeight : 0)
            let x = segmentWidth * CGFloat(idx) + (segmentWidth - imageWidth)/2.0
            let rect = CGRect(x: x, y: y, width: imageWidth, height: imageHeight)
            
            let imageLayer = CALayer(layer: layer)
            imageLayer.frame = rect
            
            if selectedSegmentIndex == idx && !sectionSelectedImages.isEmpty {
                let highlightIcon = sectionSelectedImages[idx]
                imageLayer.contents = highlightIcon.cgImage
            } else {
                imageLayer.contents = icon.cgImage
            }
            
            scrollView.layer.addSublayer(imageLayer)
            // Vertical Divider
            if isVerticalDividerEnabled && idx > 0 {
                let verticalDividerLayer = CALayer(layer: layer)
                verticalDividerLayer.frame = CGRect(x: (segmentWidth * CGFloat(idx)) - (verticalDividerWidth / 2),
                                                    y: selectionIndicatorHeight * 2,
                                                    width: verticalDividerWidth,
                                                    height: frame.size.height-(selectionIndicatorHeight * 4))
                
                verticalDividerLayer.backgroundColor = self.verticalDividerColor.cgColor
                scrollView.layer.addSublayer(verticalDividerLayer)
            }
            
            addBackgroundAndBorderLayer(rect: rect)
        }
    }
    
    private func drawForTextImageType(_ oldRect: CGRect) {
        for (idx, iconImage) in sectionImages.enumerated() {
            let icon = iconImage
            let imageSize = icon.size
            let stringSize = measureTitle(at: idx)
            var rects: (textRect: CGRect, imageRect: CGRect)
            switch segmentWidthStyle {
            case .fixed: rects = fixedTextImageRects(for: idx, stringSize: stringSize, imageSize: imageSize)
            case .dynamic: rects = dynamicTextImageRects(for: idx, stringSize: stringSize, imageSize: imageSize)
            }
            
            let titleLayer = CATextLayer(layer: layer)
            titleLayer.frame = rects.textRect
            titleLayer.alignmentMode = kCAAlignmentCenter
            titleLayer.string = attributedTitle(at: idx)
            if #available(*, iOS 10.0) {
                titleLayer.truncationMode = kCATruncationEnd
            }
            let imageLayer = CALayer(layer: layer)
            imageLayer.frame = rects.imageRect
            
            if selectedSegmentIndex == idx && !sectionSelectedImages.isEmpty {
                let highlightIcon = sectionSelectedImages[idx]
                imageLayer.contents = highlightIcon.cgImage
            } else {
                imageLayer.contents = icon.cgImage
            }
            
            scrollView.layer.addSublayer(imageLayer)
            titleLayer.contentsScale = UIScreen.main.scale
            scrollView.layer.addSublayer(titleLayer)
            
            addBackgroundAndBorderLayer(rect: rects.imageRect)
        }
    }
    
    private func fixedTextImageRects(for index: Int, stringSize: CGSize, imageSize: CGSize) -> (textRect: CGRect, imageRect: CGRect) {
        var imageXOffset = segmentWidth * CGFloat(index) // Start with edge inset
        var textXOffset = segmentWidth * CGFloat(index)
        var imageYOffset = ceil((frame.height - imageSize.height) / 2.0) // Start in center
        var textYOffset = ceil((frame.height - stringSize.height) / 2.0)
        
        let isImageInLineWidthText = (imagePosition == .leftOfText || imagePosition == .rightOfText)
        if isImageInLineWidthText {
            let whitespace = segmentWidth - stringSize.width - imageSize.width - textImageSpacing
            if imagePosition == .leftOfText {
                imageXOffset += whitespace / 2.0
                textXOffset = imageXOffset + imageSize.width + textImageSpacing
            } else {
                textXOffset += whitespace / 2.0
                imageXOffset = textXOffset + stringSize.width + self.textImageSpacing
            }
        } else {
            imageXOffset = segmentWidth * CGFloat(index) + (segmentWidth - imageSize.width) / 2.0 // Start with edge inset
            textXOffset  = segmentWidth * CGFloat(index) + (segmentWidth - stringSize.width) / 2.0
            
            let whitespace = frame.height - imageSize.height - stringSize.height - textImageSpacing
            if imagePosition == .aboveText {
                imageYOffset = ceil(whitespace / 2.0)
                textYOffset = imageYOffset + imageSize.height + textImageSpacing
            } else if imagePosition == .belowText {
                textYOffset = ceil(whitespace / 2.0)
                imageYOffset = textYOffset + stringSize.height + textImageSpacing
            }
        }
        return (textRect: CGRect(x: ceil(textXOffset), y: ceil(textYOffset),
                                 width: ceil(stringSize.width), height: ceil(stringSize.height)),
                imageRect: CGRect(x: imageXOffset, y: imageYOffset, width: imageSize.width, height: imageSize.height))
        
    }
    
    private func dynamicTextImageRects(for index: Int, stringSize: CGSize, imageSize: CGSize) -> (textRect: CGRect, imageRect: CGRect) {
        var imageXOffset = segmentWidth * CGFloat(index) // Start with edge inset
        var textXOffset = segmentWidth * CGFloat(index)
        var imageYOffset = ceil((frame.height - imageSize.height) / 2.0) // Start in center
        var textYOffset = ceil((frame.height - stringSize.height) / 2.0)
        
        var xOffset: CGFloat = 0
        var i = 0
        for width in segmentWidthsArray {
            if index == i { break }
            xOffset += width
            i += 1
        }
        
        let isImageInLineWidthText = (imagePosition == .leftOfText || imagePosition == .rightOfText)
        if isImageInLineWidthText {
            if imagePosition == .leftOfText {
                imageXOffset = xOffset
                textXOffset = imageXOffset + imageSize.width + textImageSpacing
            } else {
                textXOffset = xOffset
                imageXOffset = textXOffset + stringSize.width + textImageSpacing
            }
        } else {
            imageXOffset = xOffset + (segmentWidthsArray[i] - imageSize.width) / 2.0 // Start with edge inset
            textXOffset  = xOffset + (segmentWidthsArray[i] - stringSize.width) / 2.0
            
            let whitespace = frame.height - imageSize.height - stringSize.height - textImageSpacing
            if imagePosition == .aboveText {
                imageYOffset = ceil(whitespace / 2.0)
                textYOffset = imageYOffset + imageSize.height + textImageSpacing
            } else if imagePosition == .belowText {
                textYOffset = ceil(whitespace / 2.0)
                imageYOffset = textYOffset + stringSize.height + textImageSpacing
            }
        }
        return (textRect: CGRect(x: ceil(textXOffset), y: ceil(textYOffset),
                                 width: ceil(stringSize.width), height: ceil(stringSize.height)),
                imageRect: CGRect(x: imageXOffset, y: imageYOffset, width: imageSize.width, height: imageSize.height))
    }
    
    func addBackgroundAndBorderLayer(rect fullRect: CGRect) {
        // Background layer
        let backgroundLayer = CALayer(layer: layer)
        backgroundLayer.frame = fullRect
        layer.insertSublayer(backgroundLayer, at: 0)
        
        // Border layer
        switch borderType {
        case .top:
            let borderLayer = CALayer(layer: layer)
            borderLayer.frame = CGRect(x: 0, y: 0, width: fullRect.size.width, height: borderWidth)
            borderLayer.backgroundColor = borderColor.cgColor
            backgroundLayer.addSublayer(borderLayer)
        case .left:
            let borderLayer = CALayer(layer: layer)
            borderLayer.frame = CGRect(x: 0, y: 0, width: borderWidth, height: fullRect.size.height)
            borderLayer.backgroundColor = borderColor.cgColor
            backgroundLayer.addSublayer(borderLayer)
        case .bottom:
            let borderLayer = CALayer(layer: layer)
            borderLayer.frame = CGRect(x: 0, y:  fullRect.size.height - borderWidth,
                                       width: fullRect.size.width, height: borderWidth)
            borderLayer.backgroundColor = borderColor.cgColor
            backgroundLayer.addSublayer(borderLayer)
        case .right:
            let borderLayer = CALayer(layer: layer)
            borderLayer.frame = CGRect(x: fullRect.size.width - borderWidth, y: 0,
                                       width: borderWidth, height: fullRect.size.height)
            borderLayer.backgroundColor = borderColor.cgColor
            backgroundLayer.addSublayer(borderLayer)
        default:
            break
        }
    }
    
    func setArrowFrame() {
        selectionIndicatorArrowLayer.frame = frameForSelectionIndicator()
        selectionIndicatorArrowLayer.mask = nil
        
        let arrowPath = UIBezierPath()
        var p1: CGPoint = .zero
        var p2: CGPoint = .zero
        var p3: CGPoint = .zero
        
        switch selectionIndicatorLocation {
        case .down:
            p1 = CGPoint(x: selectionIndicatorArrowLayer.bounds.size.width / 2, y: 0)
            p2 = CGPoint(x: 0, y: selectionIndicatorArrowLayer.bounds.size.height)
            p3 = CGPoint(x: selectionIndicatorArrowLayer.bounds.size.width,
                         y: selectionIndicatorArrowLayer.bounds.size.height)
        case .up:
            p1 = CGPoint(x: selectionIndicatorArrowLayer.bounds.size.width / 2,
                         y: selectionIndicatorArrowLayer.bounds.size.height)
            p2 = CGPoint(x: selectionIndicatorArrowLayer.bounds.size.width, y: 0)
            p3 = CGPoint(x: 0, y: 0)
        default:
            break
        }
        
        arrowPath.move(to: p1)
        arrowPath.addLine(to: p2)
        arrowPath.addLine(to: p3)
        arrowPath.close()
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = selectionIndicatorArrowLayer.bounds
        maskLayer.path = arrowPath.cgPath
        selectionIndicatorArrowLayer.mask = maskLayer
    }
    
    func frameForSelectionIndicator() -> CGRect {
        var indicatorYOffset: CGFloat = 0
    
        if selectionIndicatorLocation == .down {
            indicatorYOffset = bounds.size.height - selectionIndicatorHeight + selectionIndicatorEdgeInsets.bottom
        }
    
        if selectionIndicatorLocation == .up {
            indicatorYOffset = selectionIndicatorEdgeInsets.top
        }
    
        var sectionWidth: CGFloat = 0
    
        if type == .text {
            let stringWidth = measureTitle(at: selectedSegmentIndex).width
            sectionWidth = stringWidth
        } else if type == .images {
            let sectionImage = sectionImages[selectedSegmentIndex]
            let imageWidth = sectionImage.size.width
            sectionWidth = imageWidth
        } else if type == .textImages {
            let stringWidth = measureTitle(at: selectedSegmentIndex).width
            let sectionImage = sectionImages[selectedSegmentIndex]
            let imageWidth = sectionImage.size.width
            sectionWidth = max(stringWidth, imageWidth)
        }
        
        if selectionStyle == .arrow {
            let widthToEndOfSelectedSegment = (segmentWidth * CGFloat(selectedSegmentIndex)) + self.segmentWidth
            let widthToStartOfSelectedIndex = (segmentWidth * CGFloat(selectedSegmentIndex))
            
            let x = widthToStartOfSelectedIndex + ((widthToEndOfSelectedSegment - widthToStartOfSelectedIndex) / 2) - (selectionIndicatorHeight/2)
            return CGRect(x: x - (selectionIndicatorHeight / 2), y: indicatorYOffset,
                          width: selectionIndicatorHeight * 2, height: selectionIndicatorHeight)
        } else {
            if selectionStyle == .textWidthStripe && sectionWidth <= segmentWidth && segmentWidthStyle != .dynamic {
                let widthToEndOfSelectedSegment = (segmentWidth * CGFloat(selectedSegmentIndex)) + segmentWidth
                let widthToStartOfSelectedIndex = (segmentWidth * CGFloat(selectedSegmentIndex))
                
                let x = ((widthToEndOfSelectedSegment - widthToStartOfSelectedIndex) / 2) + (widthToStartOfSelectedIndex - sectionWidth / 2)
                return CGRect(x: x + selectionIndicatorEdgeInsets.left, y: indicatorYOffset,
                              width: sectionWidth - selectionIndicatorEdgeInsets.right, height: selectionIndicatorHeight)
            } else {
                if segmentWidthStyle == .dynamic {
                    var selectedSegmentOffset: CGFloat = 0
                    
                    var i = 0
                    for width in segmentWidthsArray {
                        if selectedSegmentIndex == i { break }
                        selectedSegmentOffset += width
                        i += 1
                    }
                    return CGRect(x: selectedSegmentOffset + selectionIndicatorEdgeInsets.left,
                                  y: indicatorYOffset,
                                  width: segmentWidthsArray[selectedSegmentIndex] - selectionIndicatorEdgeInsets.right,
                                  height: selectionIndicatorHeight + selectionIndicatorEdgeInsets.bottom)
                }
                
                return CGRect(x: (segmentWidth + selectionIndicatorEdgeInsets.left) * CGFloat(selectedSegmentIndex),
                              y: indicatorYOffset,
                              width: segmentWidth - selectionIndicatorEdgeInsets.right,
                              height: selectionIndicatorHeight)
            }
        }
    }
    
    func frameForFillerSelectionIndicator() -> CGRect {
        if segmentWidthStyle == .dynamic {
            var selectedSegmentOffset: CGFloat = 0
            
            var i = 0
            for width in segmentWidthsArray {
                if selectedSegmentIndex == i { break }
                selectedSegmentOffset += width
                i += 1
            }
            
            return CGRect(x: selectedSegmentOffset, y: 0,
                          width: segmentWidthsArray[selectedSegmentIndex], height: frame.height)
        }
        return CGRect(x: segmentWidth * CGFloat(selectedSegmentIndex), y: 0, width: segmentWidth, height: frame.height)
    }
    
    func updateSegmentsRects() {
        scrollView.contentInset = .zero
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        if sectionCount > 0 {
            segmentWidth = frame.width / CGFloat(sectionCount)
        }
        
        if type == .text && segmentWidthStyle == .fixed {
            for (idx, _) in sectionTitles.enumerated() {
                let stringWidth = measureTitle(at: idx).width + segmentEdgeInset.left + segmentEdgeInset.right
                segmentWidth = max(stringWidth, segmentWidth)
            }
        } else if type == .text && segmentWidthStyle == .dynamic {
            var mutableSegmentWidths = [CGFloat]()
            var totalWidth: CGFloat = 0
            
            for (idx, _) in sectionTitles.enumerated() {
                let stringWidth = measureTitle(at: idx).width + segmentEdgeInset.left + segmentEdgeInset.right
                totalWidth += stringWidth
                mutableSegmentWidths.append(stringWidth)
            }
            
            if shouldStretchSegmentsToScreenSize && totalWidth < bounds.size.width {
                let whitespace = bounds.size.width - totalWidth
                let whitespaceForSegment = whitespace / CGFloat(mutableSegmentWidths.count)
                for (idx, obj) in mutableSegmentWidths.enumerated() {
                    let extendedWidth = whitespaceForSegment + obj
                    mutableSegmentWidths.remove(at: idx)
                    mutableSegmentWidths.insert(extendedWidth, at: idx)
                }
            }
            segmentWidthsArray = mutableSegmentWidths
            
        } else if type == .images {
            for sectionImage in sectionImages {
                let imageWidth = sectionImage.size.width + segmentEdgeInset.left + segmentEdgeInset.right
                segmentWidth = max(imageWidth, segmentWidth)
            }
        } else if type == .textImages && segmentWidthStyle == .fixed {
            //lets just use the title.. we will assume it is wider then images...
            for (idx, _) in sectionTitles.enumerated() {
                let stringWidth = measureTitle(at: idx).width + segmentEdgeInset.left + segmentEdgeInset.right
                segmentWidth = max(stringWidth, segmentWidth)
            }
        } else if type == .textImages && segmentWidthStyle == .dynamic {
            var mutableSegmentWidths = [CGFloat]()
            var totalWidth: CGFloat = 0
            
            for (idx, _) in sectionTitles.enumerated() {
                let stringWidth = measureTitle(at: idx).width + segmentEdgeInset.right
                let sectionImage = sectionImages[idx]
                let imageWidth = sectionImage.size.width + segmentEdgeInset.left
                
                var combinedWidth: CGFloat = 0
                if imagePosition == .leftOfText || imagePosition == .rightOfText {
                    combinedWidth = imageWidth + stringWidth + textImageSpacing
                } else {
                    combinedWidth = max(imageWidth, stringWidth)
                }
                
                totalWidth += combinedWidth
                
                mutableSegmentWidths.append(combinedWidth)
            }
            
            if shouldStretchSegmentsToScreenSize && totalWidth < bounds.size.width {
                let whitespace = bounds.size.width - totalWidth
                let whitespaceForSegment = whitespace / CGFloat(mutableSegmentWidths.count)
                for (idx, obj) in mutableSegmentWidths.enumerated() {
                    let extendedWidth = whitespaceForSegment + obj
                    mutableSegmentWidths.remove(at: idx)
                    mutableSegmentWidths.insert(extendedWidth, at: idx)
                }
            }
            segmentWidthsArray = mutableSegmentWidths
        }
        
        scrollView.isScrollEnabled = isUserDraggable
        scrollView.contentSize = CGSize(width: totalSegmentedControlWidth, height: frame.height)
    }
    
    var sectionCount: Int {
        switch type {
        case .text: return sectionTitles.count
        default: return sectionImages.count
        }
    }
    
    // MARK: - willMoveToSuperview
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil { return super.willMove(toSuperview: newSuperview) }
        
        if !sectionTitles.isEmpty || !sectionImages.isEmpty {
            updateSegmentsRects()
        }
    }
    
    // MARK: - Touch
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if cancelTouchesOnMovement { touchesMoved = true }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !touchesMoved else { return (touchesMoved = false) }
        let touchLocation = touch.location(in: self)
        
        let enlargeRect = CGRect(x: bounds.origin.x - enlargeEdgeInset.left,
                                 y: bounds.origin.y - enlargeEdgeInset.top,
                                 width: bounds.size.width + enlargeEdgeInset.left + enlargeEdgeInset.right,
                                 height: bounds.size.height + enlargeEdgeInset.top + enlargeEdgeInset.bottom)
        
        if enlargeRect.contains(touchLocation) {
            var segment: Int = 0
            if segmentWidthStyle == .fixed {
                segment = Int((touchLocation.x + scrollView.contentOffset.x) / segmentWidth)
            } else if segmentWidthStyle == .dynamic {
                // To know which segment the user touched, we need to loop over the widths and substract it from the x position.
                var widthLeft = (touchLocation.x + scrollView.contentOffset.x)
                for width in segmentWidthsArray {
                    widthLeft -= width
                    
                    if widthLeft <= 0 { break }
                    segment += 1
                }
            }
            
            var sectionsCount = 0
            switch type {
            case .images: sectionsCount = sectionImages.count
            default: sectionsCount = sectionTitles.count
            }
            
            guard segment != selectedSegmentIndex else { return selectedIndexTappedBlock() }
            if segment < sectionsCount && isTouchEnabled {
                setSelectedSegmentIndex(segment, animated: shouldAnimateUserSelection, notify: true)
            }
        }
    }
    
    // MARK: - Scrolling
    
    var totalSegmentedControlWidth: CGFloat {
        if type == .text && segmentWidthStyle == .fixed {
            return CGFloat(sectionTitles.count) * segmentWidth
        } else if segmentWidthStyle == .dynamic {
            return segmentWidthsArray.sum()
        } else {
            return CGFloat(sectionImages.count) * segmentWidth
        }
    }
    
    func scrollToSelectedSegmentIndex(animated: Bool) {
        var rectForSelectedIndex: CGRect = .zero
        var selectedSegmentOffset: CGFloat = 0
        if segmentWidthStyle == .fixed {
            rectForSelectedIndex = CGRect(x: segmentWidth * CGFloat(selectedSegmentIndex),
                                          y: 0,
                                          width: segmentWidth,
                                          height: frame.height)
            
            selectedSegmentOffset = (frame.height / 2) - (segmentWidth / 2)
        } else {
            var i = 0
            var offsetter: CGFloat = 0
            for width in segmentWidthsArray {
                if selectedSegmentIndex == i { break }
                offsetter += width
                i += 1
            }
            
            rectForSelectedIndex = CGRect(x: offsetter,
                                          y: 0,
                                          width: segmentWidthsArray[selectedSegmentIndex],
                                          height: frame.height)
            
            selectedSegmentOffset = (frame.width / 2) - (segmentWidthsArray[selectedSegmentIndex] / 2)
        }
        
        
        var rectToScrollTo = rectForSelectedIndex
        rectToScrollTo.origin.x -= selectedSegmentOffset
        rectToScrollTo.size.width += selectedSegmentOffset * 2
        scrollView.scrollRectToVisible(rectToScrollTo, animated: animated)
    }
    
    // MARK: - Index Change
    
    public func setSelectedSegmentIndex(_ index: Int, animated: Bool = false) {
        setSelectedSegmentIndex(index, animated: animated, notify: false)
    }
    
    func setSelectedSegmentIndex(_ index: Int, animated: Bool, notify: Bool) {
        selectedSegmentIndex = index
        setNeedsDisplay()
        
        if index == DMSegmentedControl.NoSegment {
            selectionIndicatorArrowLayer.removeFromSuperlayer()
            selectionIndicatorStripLayer.removeFromSuperlayer()
            selectionIndicatorBoxLayer.removeFromSuperlayer()
        } else {
            scrollToSelectedSegmentIndex(animated: animated)
            guard !addSelectionIndicatorLayersIfNeeded(for: index) else { return }
            if notify { notifyForSegmentChangeToIndex(index) }
            moveSelectionIndicators(animated: animated)
        }
    }
    
    private func addSelectionIndicatorLayersIfNeeded(for index: Int) -> Bool {
        guard selectedSegmentIndex != DMSegmentedControl.NoSegment else { return false }
        if selectionStyle == .arrow {
            if selectionIndicatorArrowLayer.superlayer == nil {
                scrollView.layer.addSublayer(selectionIndicatorArrowLayer)
                setSelectedSegmentIndex(index, animated: false, notify: true)
                return true
            }
        } else {
            if selectionIndicatorStripLayer.superlayer == nil {
                scrollView.layer.addSublayer(selectionIndicatorStripLayer)
                if selectionStyle == .box && selectionIndicatorBoxLayer.superlayer == nil {
                    scrollView.layer.insertSublayer(selectionIndicatorBoxLayer, at: 0)
                }
                setSelectedSegmentIndex(index, animated:false, notify: true)
                return true
            }
        }
        return false
    }
    
    func notifyForSegmentChangeToIndex(_ index: Int) {
        if self.superview != nil {
            sendActions(for: .valueChanged)
        }
        
        if let indexChangeBlock = self.indexChangeBlock {
            indexChangeBlock(index)
        }
    }
    
    private func moveSelectionIndicators(animated: Bool) {
        selectionIndicatorArrowLayer.actions = nil
        selectionIndicatorStripLayer.actions = nil
        selectionIndicatorBoxLayer.actions = nil
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(animated ? 0.15: 0)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
        setArrowFrame()
        selectionIndicatorBoxLayer.frame = frameForSelectionIndicator()
        selectionIndicatorStripLayer.frame = frameForSelectionIndicator()
        self.selectionIndicatorBoxLayer.frame = frameForFillerSelectionIndicator()
        CATransaction.commit()
    }
    
    // MARK: - Styling Support
    
    var resultingTitleTextAttributes: [NSAttributedStringKey : Any] {
        var resultingAttrs: [NSAttributedStringKey : Any] = [
            .font : UIFont.systemFont(ofSize: 19),
            .foregroundColor : UIColor.black
        ]
        for (k, v) in titleTextAttributes { resultingAttrs[k] = v }
    
        return resultingAttrs
    }
    
    var resultingSelectedTitleTextAttributes: [NSAttributedStringKey : Any] {
        var resultingAttrs = resultingTitleTextAttributes
        for (k, v) in selectedTitleTextAttributes { resultingAttrs[k] = v }
        return resultingAttrs
    }
    
}

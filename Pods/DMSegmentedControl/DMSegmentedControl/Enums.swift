//
//  Enums.swift
//  DMSegmentedControl
//
//  Created by Dominic on 9/5/18.
//  Copyright © 2018 DominicMiller. All rights reserved.
//

import UIKit

public enum DMSegmentedControlSelectionStyle: Int {
    case textWidthStripe,   // Indicator width will only be as big as the text width
    fullWidthStripe,        // Indicator width will fill the whole segment
    box,                    // A rectangle that covers the whole segment
    arrow                   // An arrow in the middle of the segment pointing up or down
}

public enum DMSegmentedControlSelectionIndicatorLocation: Int {
    case up,
    down,
    none // No selection indicator
}

public enum DMSegmentedControlSegmentWidthStyle: Int {
    case fixed, // Segment width is fixed
    dynamic // Segment width will only be as big as the text width (including inset)
}

public struct DMSegmentedControlBorderType: OptionSet {
    public let rawValue: Int64
    public init(rawValue:Int64){ self.rawValue = rawValue }
    
    public static let none = DMSegmentedControlBorderType(rawValue: 0)
    public static let top = DMSegmentedControlBorderType(rawValue: (1 << 0))
    public static let left = DMSegmentedControlBorderType(rawValue: (1 << 1))
    public static let bottom = DMSegmentedControlBorderType(rawValue: (1 << 2))
    public static let right = DMSegmentedControlBorderType(rawValue: (1 << 3))
}

public extension DMSegmentedControl {
    public static let NoSegment = -1   // Segment index for no selected segment
}

public enum DMSegmentedControlType: Int {
    case text,
    images,
    textImages
}

public enum DMSegmentedControlImagePosition: Int {
    case behindText,
    leftOfText,
    rightOfText,
    aboveText,
    belowText
}

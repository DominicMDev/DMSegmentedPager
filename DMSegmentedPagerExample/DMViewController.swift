//
//  DMViewController.swift
//  DMSegmentedPagerExample
//
//  Created by Dominic on 9/10/18.
//  Copyright © 2018 DominicMiller. All rights reserved.
//

import UIKit
import DMPagerView
import DMSegmentedPager
import DMParallaxHeader

class DMViewController: DMSegmentedPagerController {

    @IBOutlet var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedPager.backgroundColor = .white
        
        // Parallax Header       
        segmentedPager.parallaxHeader.view = headerView
        segmentedPager.parallaxHeader.mode = .fill
        segmentedPager.parallaxHeader.height = 150
        segmentedPager.parallaxHeader.minimumHeight = 20
        
        // Segmented Control customization
        segmentedPager.segmentedControl.selectionIndicatorLocation = .down
        segmentedPager.segmentedControl.backgroundColor = .white
        segmentedPager.segmentedControl.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
        segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.orange]
        segmentedPager.segmentedControl.selectionStyle = .fullWidthStripe
        segmentedPager.segmentedControl.selectionIndicatorColor = .orange
    }
    
    func segmentedPager(_ segmentedPager: DMSegmentedPager, titleForSectionAt index: Int) -> String {
        return ["Table", "Web", "Text"][index]
    }
    
    func segmentedPager(_ segmentedPager: DMSegmentedPager, didScrollWith parallaxHeader: DMParallaxHeader) {
        print("progress \(parallaxHeader.progress)")
    }
}

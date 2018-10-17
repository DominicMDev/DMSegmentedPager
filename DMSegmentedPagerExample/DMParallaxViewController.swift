//
//  DMParallaxViewController.swift
//  DMSegmentedPagerExample
//
//  Created by Dominic on 9/10/18.
//  Copyright © 2018 DominicMiller. All rights reserved.
//

import UIKit
import DMSegmentedPager

class DMParallaxViewController: DMSegmentedPagerController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var headerView: UIView!
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: view.frame)
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    lazy var customView: DMCustomView = {
        return DMCustomView(frame: view.frame)
    }()
    
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
        segmentedPager.segmentedControl.titleTextAttributes = [.foregroundColor : UIColor.black]
        segmentedPager.segmentedControl.selectedTitleTextAttributes = [.foregroundColor : UIColor.orange]
        segmentedPager.segmentedControl.selectionStyle = .fullWidthStripe
        segmentedPager.segmentedControl.selectionIndicatorColor = .orange
        
        segmentedPager.segmentedControl.segmentEdgeInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    func heightForSegmentedControlInSegmentedPager(_ segmentedPager: DMSegmentedPager) -> CGFloat {
        return 30
    }
    
    func segmentedPager(_ segmentedPager: DMSegmentedPager, didSelectPageWith title: String) {
        print("\(title) page selected.")
    }
    
    func segmentedPager(_ segmentedPager: DMSegmentedPager, didScrollWith parallaxHeader: DMParallaxHeader) {
//        print("progress \(parallaxHeader.progress)")
    }
    
    override func numberOfPages(in segmentedPager: DMSegmentedPager) -> Int {
        return 4
    }
    
    func segmentedPager(_ segmentedPager: DMSegmentedPager, titleForSectionAt index: Int) -> String {
        return ["Table", "Web", "Text", "Custom"][index]
    }
    
    override func segmentedPager(_ segmentedPager: DMSegmentedPager, viewForPageAt index: Int) -> UIView {
        switch index {
        case 0: return tableView
        case 3: return customView
        default: return super.segmentedPager(segmentedPager, viewForPageAt: index)
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath.row % 2) + 1
        segmentedPager.pager.showPage(at: index, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellId")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")
        }
        cell!.textLabel?.text = (indexPath.row % 2) == 0 ? "Web" : "Text"
        return cell!
    }
    
}

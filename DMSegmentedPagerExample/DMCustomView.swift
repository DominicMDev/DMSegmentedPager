//
//  DMCustomView.swift
//  DMSegmentedPagerExample
//
//  Created by Dominic Miller on 9/14/18.
//  Copyright © 2018 DominicMiller. All rights reserved.
//

import UIKit
import DMSegmentedPager

class DMCustomView: UIView, DMPageProtocol, UITableViewDelegate, UITableViewDataSource {
    
    lazy var table1: UITableView = {
        let table = UITableView(frame: .zero)
        table.delegate = self
        table.dataSource = self
        addSubview(table)
        return table
    }()
    
    lazy var table2: UITableView = {
        let table = UITableView(frame: .zero)
        table.delegate = self
        table.dataSource = self
        addSubview(table)
        return table
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        table1.frame = CGRect(x: 0, y: 0, width: frame.width / 2, height: frame.height)
        table2.frame = CGRect(x: frame.width / 2, y: 0, width: table1.frame.width, height: table1.frame.height)
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
        cell!.textLabel?.text = "Row \(indexPath.row)"
        return cell!
    }
    
    // MARK: - DMPageProtocol
    
    func segmentedPager(_ segmentedPager: DMSegmentedPager, shouldScrollWith view: UIView) -> Bool {
        return view != table2
    }
    
}

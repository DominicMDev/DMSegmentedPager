//
//  DMTextViewController.swift
//  DMSegmentedPagerExample
//
//  Created by Dominic on 9/10/18.
//  Copyright © 2018 DominicMiller. All rights reserved.
//

import UIKit

class DMTextViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let filePath = Bundle.main.path(forResource: "LongText", ofType: "txt")
        textView.text = try! String(contentsOfFile: filePath!, encoding: .utf8)
    }
    
}

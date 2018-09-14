//
//  DMWebViewController.swift
//  DMSegmentedPagerExample
//
//  Created by Dominic on 9/10/18.
//  Copyright © 2018 DominicMiller. All rights reserved.
//

import UIKit
import WebKit

class DMWebViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://nshipster.com/")!
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

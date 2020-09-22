//
//  ViewController.swift
//  Insensibility
//
//  Created by andrew020 on 09/03/2020.
//  Copyright (c) 2020 andrew020. All rights reserved.
//

import UIKit
import Insensibility
import SnapKit
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler {

    var dataSource: [String] = []
    let webView = InAppWebView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.addSubview(webView)
        webView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        webView.addJSHandler(self, name: "closeView")
        webView.load(URLRequest(url: URL(string: "https://www.baidu.com")!))
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
}


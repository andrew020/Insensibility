//
//  InAppWebViewController.swift
//  InAppWebView
//
//  Created by 李宗良 on 2020/8/31.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

public class InAppWebViewController: UIViewController {

    public let webView: InAppWebView!
    private var progressBar: UIProgressView! = UIProgressView()

    public init(configuration: WKWebViewConfiguration? = nil) {
        webView = InAppWebView(frame: .zero, configuration: configuration)
        super.init(nibName: nil, bundle: nil)
    }
    
    public class func `default`() -> InAppWebViewController {
        return InAppWebViewController(configuration: InAppWebView.defaultConfigration())
    }
    
    required public init?(coder: NSCoder) {
        webView = InAppWebView(frame: .zero, configuration: InAppWebView.defaultConfigration())
        super.init(coder: coder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webView)
        webView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(view)
        }
        
        progressBar.tintColor = UIColor.blue
        progressBar.isHidden = true
        view.addSubview(progressBar)
        progressBar.snp.makeConstraints { (maker) in
            maker.top.trailing.leading.equalTo(view)
            maker.height.equalTo(2)
        }
        
        webView.load(URLRequest(url: URL(string: "https://www.baidu.com")!))
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: [.new], context: nil)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressBar.progress = change?[NSKeyValueChangeKey.newKey] as? Float ?? 0
            progressBar.isHidden = progressBar.progress == 0 || progressBar.progress == 1
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

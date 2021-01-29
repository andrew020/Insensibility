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

open class InAppWebViewController: UIViewController, WKUIDelegate {

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
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        view.addSubview(webView)
        webView.snp.makeConstraints { (maker) in
            if #available(iOS 11.0, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                maker.top.equalToSuperview().offset(20)
            }
            maker.bottom.leading.trailing.equalToSuperview()
        }
        
        progressBar.tintColor = UIColor.blue
        progressBar.isHidden = true
        view.addSubview(progressBar)
        progressBar.snp.makeConstraints { (maker) in
            maker.top.trailing.leading.equalTo(webView)
            maker.height.equalTo(2)
        }
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: [.new], context: nil)
        webView.viewController = self
        webView.uiDelegate = self
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressBar.progress = change?[NSKeyValueChangeKey.newKey] as? Float ?? 0
            progressBar.isHidden = progressBar.progress == 0 || progressBar.progress == 1
        }
    }

    public func webViewDidClose(_ webView: WKWebView) {
        let viewcontroller = (navigationController ?? self)
        viewcontroller.dismiss(animated: true, completion: nil)
    }
}

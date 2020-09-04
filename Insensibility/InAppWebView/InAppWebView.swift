//
//  InAppWebView.swift
//  InAppWebView
//
//  Created by 李宗良 on 2020/8/31.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit
import WebKit

@available(iOS 8.0, *)
extension WKProcessPool {
    static let shared = {
        return WKProcessPool()
    }()
}

@available(iOS 10.0, *)
open class InAppWebView: WKWebView {
    
    public var openLinkInNewWindow: Bool = false
    weak public var viewController: UIViewController?
    
    weak private var inAppNavigationDelegate: WKNavigationDelegate?
    weak internal var inAppUIDelegate: WKUIDelegate?
    
    class func defaultConfigration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.processPool = WKProcessPool.shared
        return configuration
    }
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration? = nil) {
        super.init(frame: frame, configuration: configuration ?? InAppWebView.defaultConfigration())
        self.uiDelegate = self;
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

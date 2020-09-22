//
//  InAppWebView.swift
//  InAppWebView
//
//  Created by 李宗良 on 2020/8/31.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit
import WebKit

extension WKProcessPool {
    static let shared = {
        return WKProcessPool()
    }()
}

/// 防止循环引用
public class InAppWebViewScriptMessageHandlerWrapper: NSObject, WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        handler?.userContentController(userContentController, didReceive: message)
    }
    
    public weak var handler: WKScriptMessageHandler? = nil
}

open class InAppWebView : WKWebView {
    
    public var openLinkInNewWindow: Bool = false
    weak public var viewController: UIViewController?

    weak internal var inAppUIDelegate: WKUIDelegate?
    
    public class func defaultConfigration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.processPool = WKProcessPool.shared
        configuration.userContentController = WKUserContentController()
        return configuration
    }
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration? = nil) {
        super.init(frame: frame, configuration: configuration ?? InAppWebView.defaultConfigration())
        self.uiDelegate = self;
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// 建议使用这个方法增加 js 调用监控，内部会生成一个中间变量，防止循环引用
    /// - Parameters:
    ///   - handler: 回调对象
    ///   - name: 方法名
    public func addJSHandler(_ handler: WKScriptMessageHandler, name: String) -> Void {
        let wrapper = InAppWebViewScriptMessageHandlerWrapper()
        wrapper.handler = handler
        configuration.userContentController.add(wrapper, name: name)
    }
}

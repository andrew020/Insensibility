//
//  InAppUIDelegate.swift
//  InAppWebView
//
//  Created by 李宗良 on 2020/8/31.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

extension InAppWebView {
    @objc func closePopWindow(_ sender: UIButton) -> Void {
        guard let webView = sender.superview as? InAppWebView else {
            return
        }
        webView.removeFromSuperview()
    }
    
    func viewControllerCanBePresenting() -> UIViewController? {
        if (viewController != nil) {
            return viewController
        }
        
        var topViewController = UIApplication.shared.delegate?.window??.rootViewController
        while true {
            if topViewController?.presentedViewController != nil {
                topViewController = topViewController?.presentedViewController
            } else if (topViewController is UINavigationController) && (topViewController as? UINavigationController)?.topViewController != nil {
                topViewController = (topViewController as? UINavigationController)?.topViewController
            } else if topViewController is UITabBarController {
                let tab = topViewController as? UITabBarController
                topViewController = tab?.selectedViewController
            } else {
                break
            }
        }
        return topViewController
    }
}

extension InAppWebView: WKUIDelegate {
    open override var uiDelegate: WKUIDelegate? {
        set {
            super.uiDelegate = self;
            if newValue?.superclass != self.superclass {
                inAppUIDelegate = newValue
            }
        }
        get {
            return super.uiDelegate
        }
    }
    
    /** @abstract Creates a new web view.
     @param webView The web view invoking the delegate method.
     @param configuration The configuration to use when creating the new web
     view. This configuration is a copy of webView.configuration.
     @param navigationAction The navigation action causing the new web view to
     be created.
     @param windowFeatures Window features requested by the webpage.
     @result A new web view or nil.
     @discussion The web view returned must be created with the specified configuration. WebKit will load the request in the returned web view.
    
     If you do not implement this method, the web view will cancel the navigation.
     */
    @available(iOS 8.0, *)
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let sel: Selector = #selector(webView(_:createWebViewWith:for:windowFeatures:))
        if inAppUIDelegate?.responds(to: sel) ?? false {
            return inAppUIDelegate!.webView?(webView, createWebViewWith: configuration, for: navigationAction, windowFeatures: windowFeatures)
        }
        
        var newWebView: InAppWebView? = nil
        if (openLinkInNewWindow) {
            if let viewController = viewControllerCanBePresenting() {
                let webViewController = InAppWebViewController(configuration: configuration);
                viewController.present(webViewController, animated: true, completion: nil);
                newWebView = webViewController.webView
            } else {
                let outsidePadding: CGFloat = 25.0
                var insets: UIEdgeInsets
                if let x = windowFeatures.x, let y = windowFeatures.y, let width = windowFeatures.width, let height = windowFeatures.height {
                    insets = UIEdgeInsets(
                        top: CGFloat.maximum(outsidePadding, CGFloat(x.floatValue)),
                        left: CGFloat.maximum(outsidePadding, CGFloat(y.floatValue)),
                        bottom: CGFloat.maximum(outsidePadding, webView.bounds.height - CGFloat(y.floatValue) - CGFloat(height.floatValue)),
                        right: CGFloat.maximum(outsidePadding, webView.bounds.width - CGFloat(x.floatValue) - CGFloat(width.floatValue))
                    )
                } else {
                    insets = UIEdgeInsets(top: outsidePadding, left: outsidePadding, bottom: outsidePadding, right: outsidePadding)
                }
                newWebView = InAppWebView(frame: CGRect.zero, configuration: configuration)
                newWebView!.layer.borderColor = UIColor.darkGray.cgColor
                newWebView!.layer.borderWidth = 2
                newWebView!.layer.shadowColor = UIColor.black.cgColor
                newWebView!.layer.shadowOffset = CGSize.zero
                newWebView!.layer.shadowRadius = 100
                newWebView!.layer.shadowOpacity = 1
                newWebView!.openLinkInNewWindow = openLinkInNewWindow;
                newWebView!.viewController = viewController
                self.addSubview(newWebView!)
                newWebView!.snp.makeConstraints { (maker) in
                    var target: ConstraintRelatableTarget
                    if #available(iOS 11.0, *) {
                        target = webView.safeAreaLayoutGuide
                    } else {
                        target = webView
                    }
                    maker.top.equalTo(target).offset(insets.top)
                    maker.bottom.equalTo(target).offset(-insets.bottom)
                    maker.left.equalTo(target).offset(insets.left)
                    maker.right.equalTo(target).offset(-insets.right)
                }
                
                var close: UIButton!
                if #available(iOS 13.0, *) {
                    close = UIButton(type: .close)
                } else {
                    close = UIButton(type: .system)
                    close.layer.cornerRadius = 20
                    close.layer.masksToBounds = true
                    close.setTitleColor(UIColor.white, for: .normal)
                    close.setTitle("X", for: .normal)
                    close.backgroundColor = UIColor.gray
                }
                close.tintColor = UIColor.black
                close.frame = CGRect(x: frame.width - 50, y: 10, width: 40, height: 40)
                close.setTitleShadowColor(UIColor.white, for: .normal)
                close.addTarget(self, action: #selector(closePopWindow(_:)), for: .touchUpInside)
                newWebView!.addSubview(close)
                close.snp.makeConstraints { (maker) in
                    maker.size.equalTo(CGSize(width: 40, height: 40))
                    var target: ConstraintRelatableTarget
                    if #available(iOS 11.0, *) {
                        target = newWebView!.safeAreaLayoutGuide
                    } else {
                        target = newWebView!
                    }
                    maker.top.equalTo(target).offset(10)
                    maker.trailing.equalTo(target).offset(-10)
                }
            }
        } else {
            webView.load(navigationAction.request)
        }
        return newWebView;
    }

    
    /** @abstract Notifies your app that the DOM window object's close() method completed successfully.
      @param webView The web view invoking the delegate method.
      @discussion Your app should remove the web view from the view hierarchy and update
      the UI as needed, such as by closing the containing browser tab or window.
      */
    @available(iOS 9.0, *)
    public func webViewDidClose(_ webView: WKWebView) {
        let sel: Selector = #selector(webViewDidClose(_:))
        if inAppUIDelegate?.responds(to: sel) ?? false {
            inAppUIDelegate?.webViewDidClose?(self)
            return
        }
        
        guard let webView = webView as? InAppWebView else {
            return
        }
        if webView.viewController != nil && webView.viewController != viewController {
            webView.viewController?.dismiss(animated: true, completion: nil)
        } else {
            webView.removeFromSuperview()
        }
    }

    
    /** @abstract Displays a JavaScript alert panel.
     @param webView The web view invoking the delegate method.
     @param message The message to display.
     @param frame Information about the frame whose JavaScript initiated this
     call.
     @param completionHandler The completion handler to call after the alert
     panel has been dismissed.
     @discussion For user security, your app should call attention to the fact
     that a specific website controls the content in this panel. A simple forumla
     for identifying the controlling website is frame.request.URL.host.
     The panel should have a single OK button.
    
     If you do not implement this method, the web view will behave as if the user selected the OK button.
     */
    @available(iOS 8.0, *)
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let sel: Selector = #selector(webView(_:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:))
        if inAppUIDelegate?.responds(to: sel) ?? false {
            inAppUIDelegate?.webView?(self, runJavaScriptAlertPanelWithMessage: message, initiatedByFrame: frame, completionHandler: completionHandler)
            return
        }
        
        let alert = UIAlertController(title: String(message.utf8), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("js_alert_ok", comment: "OK"), style: .cancel, handler: { (_) in
            completionHandler()
        }))
        viewControllerCanBePresenting()?.present(alert, animated: true, completion: nil)
    }

    
    /** @abstract Displays a JavaScript confirm panel.
     @param webView The web view invoking the delegate method.
     @param message The message to display.
     @param frame Information about the frame whose JavaScript initiated this call.
     @param completionHandler The completion handler to call after the confirm
     panel has been dismissed. Pass YES if the user chose OK, NO if the user
     chose Cancel.
     @discussion For user security, your app should call attention to the fact
     that a specific website controls the content in this panel. A simple forumla
     for identifying the controlling website is frame.request.URL.host.
     The panel should have two buttons, such as OK and Cancel.
    
     If you do not implement this method, the web view will behave as if the user selected the Cancel button.
     */
    @available(iOS 8.0, *)
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let sel: Selector = #selector(webView(_:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:))
        if inAppUIDelegate?.responds(to: sel) ?? false {
            inAppUIDelegate?.webView?(self, runJavaScriptConfirmPanelWithMessage: message, initiatedByFrame: frame, completionHandler: completionHandler)
            return
        }
        
        let alert = UIAlertController(title: String(message.utf8), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("js_alert_ok", comment: "OK"), style: .cancel, handler: { (_) in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("js_alert_cancel", comment: "Cancel"), style: .default, handler: { (_) in
            completionHandler(false)
        }))
        viewControllerCanBePresenting()?.present(alert, animated: true, completion: nil)
    }

    
    /** @abstract Displays a JavaScript text input panel.
     @param webView The web view invoking the delegate method.
     @param prompt The prompt to display.
     @param defaultText The initial text to display in the text entry field.
     @param frame Information about the frame whose JavaScript initiated this call.
     @param completionHandler The completion handler to call after the text
     input panel has been dismissed. Pass the entered text if the user chose
     OK, otherwise nil.
     @discussion For user security, your app should call attention to the fact
     that a specific website controls the content in this panel. A simple forumla
     for identifying the controlling website is frame.request.URL.host.
     The panel should have two buttons, such as OK and Cancel, and a field in
     which to enter text.
    
     If you do not implement this method, the web view will behave as if the user selected the Cancel button.
     */
    @available(iOS 8.0, *)
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let sel: Selector = #selector(webView(_:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:))
        if inAppUIDelegate?.responds(to: sel) ?? false {
            inAppUIDelegate?.webView?(self, runJavaScriptTextInputPanelWithPrompt: prompt, defaultText: defaultText, initiatedByFrame: frame, completionHandler: completionHandler)
            return
        }
        
        let alert = UIAlertController(title: String(prompt.utf8), message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            if let defaultText = defaultText {
                textField.text = String(defaultText.utf8)
            }
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("js_alert_ok", comment: "OK"), style: .cancel, handler: { (_) in
            completionHandler(alert.textFields?.last?.text ?? "")
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("js_alert_cancel", comment: "Cancel"), style: .default, handler: nil))
        viewControllerCanBePresenting()?.present(alert, animated: true, completion: nil)
    }

    
    /** @abstract Allows your app to determine whether or not the given element should show a preview.
     @param webView The web view invoking the delegate method.
     @param elementInfo The elementInfo for the element the user has started touching.
     @discussion To disable previews entirely for the given element, return NO. Returning NO will prevent
     webView:previewingViewControllerForElement:defaultActions: and webView:commitPreviewingViewController:
     from being invoked.
     
     This method will only be invoked for elements that have default preview in WebKit, which is
     limited to links. In the future, it could be invoked for additional elements.
     */
    @available(iOS, introduced: 10.0, deprecated: 13.0)
    public func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return inAppUIDelegate?.webView?(webView, shouldPreviewElement: elementInfo) ?? true
    }

    
    /** @abstract Allows your app to provide a custom view controller to show when the given element is peeked.
     @param webView The web view invoking the delegate method.
     @param elementInfo The elementInfo for the element the user is peeking.
     @param defaultActions An array of the actions that WebKit would use as previewActionItems for this element by
     default. These actions would be used if allowsLinkPreview is YES but these delegate methods have not been
     implemented, or if this delegate method returns nil.
     @discussion Returning a view controller will result in that view controller being displayed as a peek preview.
     To use the defaultActions, your app is responsible for returning whichever of those actions it wants in your
     view controller's implementation of -previewActionItems.
     
     Returning nil will result in WebKit's default preview behavior. webView:commitPreviewingViewController: will only be invoked
     if a non-nil view controller was returned.
     */
    @available(iOS, introduced: 10.0, deprecated: 13.0)
    public func webView(_ webView: WKWebView, previewingViewControllerForElement elementInfo: WKPreviewElementInfo, defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController? {
        return inAppUIDelegate?.webView?(webView, previewingViewControllerForElement: elementInfo, defaultActions: previewActions) ?? nil
    }

    
    /** @abstract Allows your app to pop to the view controller it created.
     @param webView The web view invoking the delegate method.
     @param previewingViewController The view controller that is being popped.
     */
    @available(iOS, introduced: 10.0, deprecated: 13.0)
    public func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController) {
        inAppUIDelegate?.webView?(webView, commitPreviewingViewController: previewingViewController)
    }

    
    // TARGET_OS_IPHONE
    
    
    /**
     * @abstract Called when a context menu interaction begins.
     *
     * @param webView The web view invoking the delegate method.
     * @param elementInfo The elementInfo for the element the user is touching.
     * @param completionHandler A completion handler to call once a it has been decided whether or not to show a context menu.
     * Pass a valid UIContextMenuConfiguration to show a context menu, or pass nil to not show a context menu.
     */
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
        inAppUIDelegate?.webView?(webView, contextMenuConfigurationForElement: elementInfo, completionHandler: completionHandler)
    }

    
    
    /**
     * @abstract Called when the context menu will be presented.
     *
     * @param webView The web view invoking the delegate method.
     * @param elementInfo The elementInfo for the element the user is touching.
     */
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, contextMenuWillPresentForElement elementInfo: WKContextMenuElementInfo) {
        inAppUIDelegate?.webView?(webView, contextMenuWillPresentForElement: elementInfo)
    }

    
    
    /**
     * @abstract Called when the context menu configured by the UIContextMenuConfiguration from
     * webView:contextMenuConfigurationForElement:completionHandler: is committed. That is, when
     * the user has selected the view provided in the UIContextMenuContentPreviewProvider.
     *
     * @param webView The web view invoking the delegate method.
     * @param elementInfo The elementInfo for the element the user is touching.
     * @param animator The animator to use for the commit animation.
     */
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, contextMenuForElement elementInfo: WKContextMenuElementInfo, willCommitWithAnimator animator: UIContextMenuInteractionCommitAnimating) {
        inAppUIDelegate?.webView?(webView, contextMenuForElement: elementInfo, willCommitWithAnimator: animator)
    }

    
    
    /**
     * @abstract Called when the context menu ends, either by being dismissed or when a menu action is taken.
     *
     * @param webView The web view invoking the delegate method.
     * @param elementInfo The elementInfo for the element the user is touching.
     */
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, contextMenuDidEndForElement elementInfo: WKContextMenuElementInfo) {
        inAppUIDelegate?.webView?(webView, contextMenuDidEndForElement: elementInfo)
    }
}

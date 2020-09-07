//
//  FadePresentationViewController.swift
//  Pods
//
//  Created by 李宗良 on 2020/9/7.
//

import UIKit

open class FadePresentationViewController: UIViewController, UIViewControllerTransitioningDelegate {

    /// 在 FadePresentationViewController 被 present 或 dismiss 的过程中，会调用此方法。
    /// 在这个方法中，只需调整内部元素的位置。
    public var presentingBlock: FadePresentation.AnimationBlock? = nil

    /// 点击空白处收起 view controller, 默认 YES
    public var dismissByTappingBlank: Bool = true
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        fadePresentationSetup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        fadePresentationSetup()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(white: 0, alpha: 0.75)

        let blankView = UIView()
        blankView.backgroundColor = UIColor.clear
        blankView.isUserInteractionEnabled = true
        blankView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappingBlank(_:))))
        view.insertSubview(blankView, at: 0)
        blankView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blankView.topAnchor.constraint(equalTo: view.topAnchor),
            blankView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blankView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blankView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func fadePresentationSetup() -> Void {
        modalPresentationStyle = .custom
        transitioningDelegate = self
        definesPresentationContext = true
        dismissByTappingBlank = true
    }
    
    @objc func tappingBlank(_ sender: Any) -> Void {
        if self.dismissByTappingBlank {
            self.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: UIViewControllerTransitioningDelegate

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadePresentation(fromVC: presenting, toVC: presented, animationBlock: presentingBlock)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presentingViewController != nil {
            let animatedTransitioning = FadePresentation(fromVC: self, toVC: presentingViewController!, animationBlock: presentingBlock)
            animatedTransitioning.presenting = false
            return animatedTransitioning
        }
        return nil
    }
}

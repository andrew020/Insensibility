//
//  FadePresentation.swift
//  Insensibility
//
//  Created by 李宗良 on 2020/9/7.
//

import UIKit

public class FadePresentation: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    public typealias AnimationBlock = (_ isPresenting: Bool) -> Void
    
    var presenting: Bool = true
    let fromVC: UIViewController
    let toVC: UIViewController
    var animationBlock: AnimationBlock? = nil
    
    init(fromVC: UIViewController, toVC: UIViewController, animationBlock: AnimationBlock?) {
        self.fromVC = fromVC
        self.toVC = toVC
        self.animationBlock = animationBlock
        
        super.init()
    }
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        if presenting {
            containerView.addSubview(toVC.view)
            toVC.view.alpha = 0
            toVC.view.frame = fromVC.view.frame;
            UIView.animate(withDuration: duration, animations: {
                self.toVC.view.alpha = 1
                self.animationBlock?(self.presenting)
            }) { finished in
                if finished {
                    self.toVC.view.alpha = 1
                    transitionContext.completeTransition(true)
                }
            }
        } else {
            UIView.animate(withDuration: duration, animations: {
                self.fromVC.view.alpha = 0
                self.animationBlock?(self.presenting)
            }) { finished in
                if finished {
                    transitionContext.completeTransition(true)
                }
            }
        }
    }
}

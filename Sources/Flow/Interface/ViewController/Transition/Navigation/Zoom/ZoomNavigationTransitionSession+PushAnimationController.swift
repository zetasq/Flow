//
//  ZoomNavigationTransitionSession+PushAnimationController.swift
//  
//
//  Created by Zhu Shengqi on 1/10/2019.
//

import Foundation
import UIKit

extension ZoomNavigationTransitionSession {
  
  public class PushAnimationController: NSObject {

    private var animator: UIViewPropertyAnimator?
    private var transitionContext: UIViewControllerContextTransitioning?
    
    private let zoomFrameInSourceViewController: CGRect
    
    public init(zoomFrameInSourceViewController: CGRect) {
      self.zoomFrameInSourceViewController = zoomFrameInSourceViewController
    }

  }
  
}

extension ZoomNavigationTransitionSession.PushAnimationController: UIViewControllerAnimatedTransitioning {
  
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.25 // This won't take effect if we use a spring animation
  }
  
  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}
  
  public func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
    return self.animator!
  }
  
  public func animationEnded(_ transitionCompleted: Bool) {
    
  }
  
}

extension ZoomNavigationTransitionSession.PushAnimationController: UIViewControllerInteractiveTransitioning {
  public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
    self.transitionContext = transitionContext
    
    let fromVC = transitionContext.viewController(forKey: .from)!
    let fromView = fromVC.view!
    let toVC = transitionContext.viewController(forKey: .to)!
    let toView = toVC.view!
    let containerView = transitionContext.containerView
    
    let visualEffectView = UIVisualEffectView(effect: nil)
    visualEffectView.frame = containerView.bounds
    visualEffectView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    containerView.addSubview(visualEffectView)

    let toViewFinalFrame = transitionContext.finalFrame(for: toVC)
    toView.frame = toViewFinalFrame
    
    let zoomFrameInContainerView = fromView.convert(self.zoomFrameInSourceViewController, to: containerView)
    toView.transform = zoomFrameInContainerView.transform(from: toViewFinalFrame)
    toView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    toView.alpha = 0
    containerView.addSubview(toView)
    
    let timingParameters = UISpringTimingParameters(mass: 4.5, stiffness: 1300, damping: 95, initialVelocity: .zero)

    let animator = UIViewPropertyAnimator(duration: self.transitionDuration(using: transitionContext), timingParameters:timingParameters)
    self.animator = animator
    
    animator.addAnimations {
      toView.transform = .identity
      toView.alpha = 1
      
      visualEffectView.effect = UIBlurEffect(style: .light)
    }
    
    animator.addCompletion { position in
      visualEffectView.removeFromSuperview()
      
      let completed = (position == .end)
      transitionContext.completeTransition(completed)
    }
    
    animator.startAnimation()
  }
  
  public var wantsInteractiveStart: Bool {
    // When a viewController is pushed, it should be always triggered by a non-interactive touch (tap)
    return false
  }
}

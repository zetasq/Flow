//
//  FilZoomNavigationTransitionSession+PopAnimationControllere.swift
//  
//
//  Created by Zhu Shengqi on 1/10/2019.
//

import Foundation
import UIKit

extension ZoomNavigationTransitionSession {
  
  public class PopAnimationController: NSObject {
    
    private var animator: UIViewPropertyAnimator?
    private var transitionContext: UIViewControllerContextTransitioning?
    
    private let zoomFrameInSourceViewController: CGRect
    
    public init(zoomFrameInSourceViewController: CGRect) {
      self.zoomFrameInSourceViewController = zoomFrameInSourceViewController
    }
    
  }
  
}

extension ZoomNavigationTransitionSession.PopAnimationController: UIViewControllerAnimatedTransitioning {
  
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.25
  }
  
  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}
  
  public func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
    return self.animator!
  }
  
  public func animationEnded(_ transitionCompleted: Bool) {
    
  }
  
}

extension ZoomNavigationTransitionSession.PopAnimationController: UIViewControllerInteractiveTransitioning {
  public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
    self.transitionContext = transitionContext
    
    let fromVC = transitionContext.viewController(forKey: .from)!
    let fromView = fromVC.view!
    let toVC = transitionContext.viewController(forKey: .to)!
    let toView = toVC.view!
    let containerView = transitionContext.containerView
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    visualEffectView.frame = containerView.bounds
    visualEffectView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    containerView.insertSubview(visualEffectView, belowSubview: fromView)
    
    toView.frame = transitionContext.finalFrame(for: toVC)
    toView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    containerView.insertSubview(toView, belowSubview: visualEffectView)
    
    let zoomFrameInContainerView = toView.convert(self.zoomFrameInSourceViewController, to: containerView)
    let fromViewTargetTransform = zoomFrameInContainerView.transform(from: fromView.frame)
    
//    let timingParameters = UICubicTimingParameters(animationCurve: .easeOut)
    let timingParameters = UISpringTimingParameters(mass: 1, stiffness: 200, damping: 2000, initialVelocity: CGVector(dx: 1, dy: 1))

    let animator = UIViewPropertyAnimator(duration: self.transitionDuration(using: transitionContext), timingParameters:timingParameters)
    self.animator = animator
    
    animator.addAnimations {
      fromView.transform = fromViewTargetTransform
      fromView.alpha = 0
      
      visualEffectView.effect = nil
    }
    
    animator.addCompletion { position in
      visualEffectView.removeFromSuperview()
      
      let completed = (position == .end)
      transitionContext.completeTransition(completed)
    }
    
    animator.startAnimation()
  }
  
  public var wantsInteractiveStart: Bool {
    // TODO
    return false
  }
}

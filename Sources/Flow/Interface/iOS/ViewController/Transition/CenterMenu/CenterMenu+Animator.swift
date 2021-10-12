//
//  CenterMenu+Animator.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 08/03/2017.
//  Copyright © 2017 Zhu Shengqi. All rights reserved.
//

import UIKit

extension CenterMenuTransitionContext {
  final class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    // MARK: - Properties
    var presenting: Bool
    
    // MARK: - Init & Deinit
    init(presenting: Bool) {
      self.presenting = presenting
      super.init()
    }
    
    // MARK: - Transition Duration
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      return 0.25
    }
    
    // MARK: - Transition Animation
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
      let containerView = transitionContext.containerView
      let containerBounds = containerView.frame
      
      let fromVC = transitionContext.viewController(forKey: .from)!
      let fromView = transitionContext.view(forKey: .from) ?? fromVC.view!
      let fromViewStartFrame = transitionContext.initialFrame(for: fromVC)
      var fromViewFinalFrame = transitionContext.finalFrame(for: fromVC)
      
      let toVC = transitionContext.viewController(forKey: .to)!
      let toView = transitionContext.view(forKey: .to) ?? toVC.view!
      var toViewStartFrame = transitionContext.initialFrame(for: toVC)
      let toViewFinalFrame = transitionContext.finalFrame(for: toVC)
      
      if presenting {
        toViewStartFrame.origin = CGPoint(x: containerBounds.midX - toViewFinalFrame.width / 2, y: containerBounds.height)
        
        toViewStartFrame.size = toViewFinalFrame.size
        
        toView.frame = toViewStartFrame
        containerView.addSubview(toView)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
          
          toView.frame = toViewFinalFrame
          
        }, completion: { _ in
          let success = !transitionContext.transitionWasCancelled
          
          // if presenting and the transition is cancelled, remove the presented view
          if !success {
            toView.removeFromSuperview()
          }
          
          transitionContext.completeTransition(success)
        })
      } else {
        fromViewFinalFrame.origin = CGPoint(x: containerBounds.midX - fromViewStartFrame.width / 2, y: containerBounds.height)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
          
          fromView.frame = fromViewFinalFrame
          
        }, completion: { _ in
          let success = !transitionContext.transitionWasCancelled
          transitionContext.completeTransition(success)
        })
      }
    }
  }
}

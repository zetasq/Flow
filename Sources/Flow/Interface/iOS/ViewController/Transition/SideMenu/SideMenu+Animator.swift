//
//  SideMenu+Animator.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 26/02/2017.
//  Copyright © 2017 Zhu Shengqi. All rights reserved.
//

import UIKit

extension SideMenuTransitionContext {
  final class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    // MARK: - Subtypes
    enum SlideDirection {
      case left
      case right
    }
    
    // MARK: - Properties
    var presenting: Bool
    var slideDirection: SlideDirection = .left
    
    // MARK: - Init & Deinit
    init(presenting: Bool) {
      self.presenting = presenting
      super.init()
    }
    
    // MARK: - Transition Duration
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      if transitionContext!.isInteractive {
        return 0.25
      } else {
        return 0.5
      }
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
        switch slideDirection {
        case .left:
          toViewStartFrame.origin = CGPoint(x: containerBounds.width, y: 0)
        case .right:
          toViewStartFrame.origin = CGPoint(x: -toViewFinalFrame.width, y: 0)
        }
        
        toViewStartFrame.size = toViewFinalFrame.size
        
        toView.frame = toViewStartFrame
        containerView.addSubview(toView)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
          
          toView.frame = toViewFinalFrame
          
        }, completion: { finished in
          
          transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
          
        })
      } else {
        switch slideDirection {
        case .left:
          fromViewFinalFrame.origin = CGPoint(x: containerBounds.width, y: 0)
        case .right:
          fromViewFinalFrame.origin = CGPoint(x: -fromViewStartFrame.width, y: 0)
        }
        
        if transitionContext.isInteractive {
          UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveLinear, animations: {
            
            fromView.frame = fromViewFinalFrame

          }, completion: { finished in
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)

          })
        } else {
          UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            
            fromView.frame = fromViewFinalFrame
            
          }, completion: { finished in
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
          })
        }
      }
    }
  }
}

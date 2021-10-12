//
//  SideMenuTransitionContext.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 26/02/2017.
//  Copyright © 2017 Zhu Shengqi. All rights reserved.
//

import UIKit

public final class SideMenuTransitionContext: TransitionContext {
  // MARK: - Subtypes
  public enum Side {
    case left
    case right
  }
  
  // MARK: - Properties
  public var side: Side = .right
  public var proportionInCompactWidth: CGFloat = 0.75
  public var proportionInRegularWidth: CGFloat = 0.25
  
  fileprivate let interactiveAnimator = InteractiveAnimator()
  
  // MARK: - Animator
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let animator = Animator(presenting: true)
    
    switch side {
    case .left:
      animator.slideDirection = .right
    case .right:
      animator.slideDirection = .left
    }
    
    return animator
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let animator = Animator(presenting: false)
    
    switch side {
    case .left:
      animator.slideDirection = .right
    case .right:
      animator.slideDirection = .left
    }
    
    return animator
  }
  
  // MARK: - Interactive Animator
  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return shouldDismissWithInteraction ? interactiveAnimator : nil
  }
  
  // MARK: - Presentation Controller
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    let controller = PresentationController(presentedViewController: presented, presenting: presenting)
    
    controller.presentationDelegate = self
    controller.side = side
    controller.proportionInCompactWidth = proportionInCompactWidth
    controller.proportionInRegularWidth = proportionInRegularWidth
    
    return controller
  }
}

// MARK: - SideMenuPresentationController Delegate
extension SideMenuTransitionContext: SideMenuPresentationControllerDelegate {
  func presentationDidFinish(_ presentedViewController: UIViewController) {
    interactiveAnimator.side = side
    interactiveAnimator.config(with: presentedViewController)
  }
}

//
//  CenterMenuTransitionContext.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 08/03/2017.
//  Copyright © 2017 Zhu Shengqi. All rights reserved.
//

import UIKit

final class CenterMenuTransitionContext: TransitionContext {
  // MARK: - Animator
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let animator = Animator(presenting: true)
    
    return animator
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let animator = Animator(presenting: false)
    
    return animator
  }
  
  // MARK: - Presentation Controller
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    presented.view.translatesAutoresizingMaskIntoConstraints = false
    
    let controller = PresentationController(presentedViewController: presented, presenting: presenting)
    
    return controller
  }
}

//
//  NavigationTransitioning.swift
//  
//
//  Created by Zhu Shengqi on 1/10/2019.
//

import Foundation
import UIKit

public typealias NavigationTransitionAnimationControlling = UIViewControllerAnimatedTransitioning & UIViewControllerInteractiveTransitioning

public protocol NavigationTransitioning {
  
  func animationControllerForNavigationOperation(_ operation: UINavigationController.Operation) -> NavigationTransitionAnimationControlling?
  
}

extension UIViewController {
  
  private static var navigationTransitionSessionKey = "navigationTransitionSessionKey"
  
  public final var navigationTransitionSession: NavigationTransitioning? {
    get {
      return objc_getAssociatedObject(self, &UIViewController.navigationTransitionSessionKey) as? NavigationTransitioning
    }
    set {
      objc_setAssociatedObject(self, &UIViewController.navigationTransitionSessionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
}

//
//  TransitionContext.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 26/02/2017.
//  Copyright © 2017 Zhu Shengqi. All rights reserved.
//

import UIKit

extension UIViewController {
  // MARK: - Associated Objects
  private static var transitionContextKey = "com.zetasq.Arsenal.transitionContextKey"
  
  public var transitionContext: TransitionContext? {
    get {
      return withUnsafePointer(to: &UIViewController.transitionContextKey) { pointer in
        return objc_getAssociatedObject(self, pointer) as? TransitionContext
      }
    }
    set {
      withUnsafePointer(to: &UIViewController.transitionContextKey) { pointer in
        objc_setAssociatedObject(self, pointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
      
      self.transitioningDelegate = transitionContext
      self.modalPresentationStyle = .custom
    }
  }
  
  // MARK: - Dismiss with interaction
  public func dismissWithInteraction(animated: Bool, completion: (() -> Void)?) {
    var topmostPresentedVC = self
    while true {
      if let parentVC = topmostPresentedVC.parent {
        topmostPresentedVC = parentVC
      } else {
        break
      }
    }
    
    topmostPresentedVC.transitionContext?.shouldDismissWithInteraction = true
    dismiss(animated: animated, completion: completion)
  }
}

public class TransitionContext: NSObject {
   internal var shouldDismissWithInteraction = false
}

extension TransitionContext: UIViewControllerTransitioningDelegate {}


//
//  BaseNavigationController.swift
//  
//
//  Created by Zhu Shengqi on 1/10/2019.
//

import Foundation
import UIKit

open class BaseNavigationController: UINavigationController {
  
  public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
    super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    
    self.commonInit()
  }

  
  public override init(rootViewController: UIViewController) {
    super.init(rootViewController: rootViewController)
    
    self.commonInit()
  }

  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    self.commonInit()
  }

  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    self.commonInit()
  }
  
  private func commonInit() {
    self.delegate = self
  }
  
}

extension BaseNavigationController: UINavigationControllerDelegate {
  
  public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    switch operation {
    case .none:
      return nil
    case .push:
      if let transitionSession = toVC.navigationTransitionSession {
        return transitionSession.animationControllerForNavigationOperation(operation)
      } else {
        return nil
      }
    case .pop:
      if let transitionSession = fromVC.navigationTransitionSession {
        return transitionSession.animationControllerForNavigationOperation(operation)
      } else {
        return nil
      }
    @unknown default:
      assertionFailure()
      return nil
    }
  }
  
  public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    // In NavigationTransitioning, we restrict that a UIViewControllerAnimatedTransitioning object must also conform to UIViewControllerInteractiveTransitioning.
    if let transitionAnimationController = animationController as? NavigationTransitionAnimationControlling {
      return transitionAnimationController
    } else {
      return nil
    }
  }
  
}


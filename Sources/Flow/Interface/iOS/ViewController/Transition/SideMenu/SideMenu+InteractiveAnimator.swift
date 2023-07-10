//
//  SideMenu+InteractiveAnimator.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 26/02/2017.
//  Copyright © 2017 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import UIKit

extension SideMenuTransitionContext {
  final class InteractiveAnimator: UIPercentDrivenInteractiveTransition {
    // MARK: - Properties
    var side: Side = .right
    
    private weak var viewController: UIViewController!
    private var interactiveViewStartFrame: CGRect = .zero
    private var validStartOrigin: CGPoint?
    
    // MARK: - Gesture Config
    func config(with viewController: UIViewController) {
      self.viewController = viewController
      let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleGesture(_:)))
      panGestureRecognizer.maximumNumberOfTouches = 1
      viewController.view.superview!.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - Gesture Handlers
    @objc
    private func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
      switch gestureRecognizer.state {
      case .began:
        interactiveViewStartFrame = viewController.view.frame
        
        let touchPoint = gestureRecognizer.location(in: gestureRecognizer.view!.superview)
        
        var distanceFromEdge: CGFloat
        switch side {
        case .right:
          distanceFromEdge = touchPoint.x - interactiveViewStartFrame.origin.x
        case .left:
          distanceFromEdge = interactiveViewStartFrame.origin.x + interactiveViewStartFrame.width - touchPoint.x
        }
        
        if distanceFromEdge > 50 {
          gestureRecognizer.isEnabled = false
          gestureRecognizer.isEnabled = true
        } else {
          validStartOrigin = distanceFromEdge >= 0 ? touchPoint : nil
          viewController.dismissWithInteraction(animated: true, completion: nil)
        }
      case .changed:
        let touchPoint = gestureRecognizer.location(in: gestureRecognizer.view!.superview)
        var progress: CGFloat
        
        switch side {
        case .right:
          if let validStartOrigin = validStartOrigin {
            progress = min(max((touchPoint.x - validStartOrigin.x) / interactiveViewStartFrame.width, 0), 1)
          } else {
            progress = min(max((touchPoint.x - interactiveViewStartFrame.origin.x) / interactiveViewStartFrame.width, 0), 1)
          }
        case .left:
          if let validStartOrigin = validStartOrigin {
            progress = min(max((validStartOrigin.x - touchPoint.x) / interactiveViewStartFrame.width, 0), 1)
          } else {
            progress = min(max((interactiveViewStartFrame.origin.x + interactiveViewStartFrame.width - touchPoint.x) / interactiveViewStartFrame.width, 0), 1)
          }
        }
        
        update(progress)
      case .cancelled:
        viewController.transitionContext?.shouldDismissWithInteraction = false
        
        cancel()
      case .ended:
        viewController.transitionContext?.shouldDismissWithInteraction = false
        
        if percentComplete > 0.3 {
          finish()
        } else {
          cancel()
        }
      case .failed, .possible:
        viewController.transitionContext?.shouldDismissWithInteraction = false

        cancel()
      @unknown default:
        fatalError()
      }
    }
  }
}

#endif

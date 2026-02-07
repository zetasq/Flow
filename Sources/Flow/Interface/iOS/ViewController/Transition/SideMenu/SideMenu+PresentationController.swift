//
//  SideMenu+PresentationController.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 26/02/2017.
//  Copyright © 2017 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import UIKit

@MainActor
protocol SideMenuPresentationControllerDelegate: AnyObject {
  func presentationDidFinish(_ presentedViewController: UIViewController)
}

extension SideMenuTransitionContext {
  final class PresentationController: UIPresentationController {
    // MARK: - Properties
    private let dimmingView: UIView
    
    var proportionInCompactWidth: CGFloat = 0.75
    var proportionInRegularWidth: CGFloat = 0.25
    
    var side: Side = .right
    weak var presentationDelegate: SideMenuPresentationControllerDelegate?
    
    // MARK: - Init & Deinit
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
      dimmingView = UIView()
      dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
      
      super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
      
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dimmingViewTapped(_:)))
      dimmingView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Animations with the Transition
    override func presentationTransitionWillBegin() {
      super.presentationTransitionWillBegin()
      
      dimmingView.frame = containerView!.bounds
      dimmingView.alpha = 0
      
      containerView!.insertSubview(dimmingView, at: 0)
      
      if let transitionCoordinator = presentedViewController.transitionCoordinator {
        transitionCoordinator.animate(alongsideTransition: { context in
          self.dimmingView.alpha = 1
        }, completion: { context in
          if context.isCancelled {
            self.dimmingView.alpha = 0
          }
        })
      } else {
        dimmingView.alpha = 1
      }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
      super.presentationTransitionDidEnd(completed)
      
      if completed {
        presentationDelegate?.presentationDidFinish(presentedViewController)
      }
    }
    
    override func dismissalTransitionWillBegin() {
      super.dismissalTransitionWillBegin()
      
      if let transitionCoordinator = presentedViewController.transitionCoordinator {
        transitionCoordinator.animate(alongsideTransition: { context in
          self.dimmingView.alpha = 0
        }, completion: { context in
          if context.isCancelled {
            self.dimmingView.alpha = 1
          }
        })
      } else {
        dimmingView.alpha = 0
      }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
      super.dismissalTransitionDidEnd(completed)
      
      if completed {
        dimmingView.removeFromSuperview()
      }
    }
    
    // MARK: - Presentation Config
    override var frameOfPresentedViewInContainerView: CGRect {
      return calculateFrameOfPresentedView(in: containerView!)
    }
    
    // MARK: - Rotation Adaption
    override func containerViewDidLayoutSubviews() {
      super.containerViewDidLayoutSubviews()
      
      guard let containerView = containerView else {
        return
      }
      
      dimmingView.frame = containerView.bounds
      presentedView!.frame = calculateFrameOfPresentedView(in: containerView)
    }
    
    // MARK: - Action Handlers
    @objc
    private func dimmingViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
      presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods
    private func calculateFrameOfPresentedView(in parentView: UIView) -> CGRect {
      var newSize: CGSize
      
      switch traitCollection.horizontalSizeClass {
      case .compact:
        newSize = CGSize(width: floor(parentView.bounds.width * proportionInCompactWidth), height: parentView.bounds.height)
      case .regular, .unspecified:
        newSize =  CGSize(width: floor(parentView.bounds.width * proportionInRegularWidth), height: parentView.bounds.height)
      @unknown default:
        fatalError()
      }
      
      var newOrigin: CGPoint
      switch side {
      case .left:
        newOrigin = CGPoint(x: 0, y: 0)
      case .right:
        newOrigin = CGPoint(x: parentView.bounds.width - newSize.width, y: 0)
      }
      
      return CGRect(origin: newOrigin, size: newSize)
    }
  }
}

#endif

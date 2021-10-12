//
//  CenterMenu+PresentationController.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 08/03/2017.
//  Copyright © 2017 Zhu Shengqi. All rights reserved.
//

import UIKit

extension CenterMenuTransitionContext {
  final class PresentationController: UIPresentationController {
    // MARK: - Properties
    private let dimmingView: UIView
    
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
      guard let presentedView = presentedView else {
        return .zero
      }
      
      presentedView.layoutIfNeeded()
      
      let origin = CGPoint(x: parentView.bounds.midX - presentedView.frame.width / 2,
                           y: parentView.bounds.midY - presentedView.frame.width / 2)
      let size = CGSize(width: presentedView.frame.width,
                        height: presentedView.frame.height)
      return CGRect(origin: origin, size: size)
    }
  }
}

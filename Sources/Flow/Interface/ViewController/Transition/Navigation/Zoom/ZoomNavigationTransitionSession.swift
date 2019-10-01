//
//  ZoomNavigationTransitionSettion.swift
//  
//
//  Created by Zhu Shengqi on 1/10/2019.
//

import Foundation
import UIKit

public final class ZoomNavigationTransitionSession: NSObject, NavigationTransitioning {
  
  private let zoomFrameInSourceViewController: CGRect
  
  public init(zoomFrameInSourceViewController: CGRect) {
    self.zoomFrameInSourceViewController = zoomFrameInSourceViewController
  }
  
  public func animationControllerForNavigationOperation(_ operation: UINavigationController.Operation) -> NavigationTransitionAnimationControlling? {
    switch operation {
    case .push:
      return PushAnimationController(zoomFrameInSourceViewController: zoomFrameInSourceViewController)
    case .pop:
      return PopAnimationController(zoomFrameInSourceViewController: zoomFrameInSourceViewController)
    default:
      assertionFailure()
      return nil
    }
  }
}

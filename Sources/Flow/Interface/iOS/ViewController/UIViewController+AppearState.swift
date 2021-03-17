//
//  UIViewController+AppearState.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/4.
//

#if os(iOS)

import Foundation
import UIKit

extension UIViewController {
  
  public enum AppearState: Int {
    case didDisappear = 0
    case willAppear = 1
    case didAppear = 2
    case willDisappear = 3
    
    public var orderForViewControllerTransitioning: Int {
      switch self {
      case .didDisappear:
        return 0
      case .willDisappear:
        return 1
      case .willAppear:
        return 2
      case .didAppear:
        return 3
      }
    }
  }
  
  // UIViewController actually has an private property named "_appearState", so this method couldn't be marked as @objc
  public var appearState: AppearState {
    let value = self.value(forKey: "_appearState") as! Int
    return AppearState(rawValue: value)!
  }
  
}

#endif

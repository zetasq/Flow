//
//  File.swift
//  
//
//  Created by Zhu Shengqi on 2019/8/5.
//

import Foundation
import FlowObjC

extension ViewControllerAppearanceState {
  
  public var orderForViewControllerTransitioning: Int {
    switch self {
    case .initial:
      return 0
    case .willDisappear:
      return 1
    case .didDisappear:
      return 2
    case .willAppear:
      return 3
    case .didAppear:
      return 4
    }
  }
  
}

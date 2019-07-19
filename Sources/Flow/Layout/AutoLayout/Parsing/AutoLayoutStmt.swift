//
//  AutoLayoutStmt.swift
//  
//
//  Created by Zhu Shengqi on 2019/7/19.
//

import Foundation
import UIKit

public struct AutoLayoutStmt {
  
  internal let _constraint: NSLayoutConstraint
  
  internal init(constraint: NSLayoutConstraint) {
    self._constraint = constraint
  }
  
  public func priority(_ priority: UILayoutPriority) -> Self {
    self._constraint.priority = priority
    return self
  }
  
  public func assignConstraint(_ constraint: inout NSLayoutConstraint?) -> Self {
    constraint = self._constraint
    return self
  }
  
}

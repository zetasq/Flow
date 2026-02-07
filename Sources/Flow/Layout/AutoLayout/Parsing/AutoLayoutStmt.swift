//
//  AutoLayoutStmt.swift
//  
//
//  Created by Zhu Shengqi on 2019/7/19.
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public struct AutoLayoutStmt {
  
  internal let _constraint: NSLayoutConstraint
  
  internal init(constraint: NSLayoutConstraint) {
    self._constraint = constraint
  }
  
  public func priority(_ priority: PlatformAgnosticLayoutPriority) -> Self {
    self._constraint.priority = priority
    return self
  }
  
  public func store(in constraint: inout NSLayoutConstraint?) -> Self {
    constraint = self._constraint
    return self
  }
  
}

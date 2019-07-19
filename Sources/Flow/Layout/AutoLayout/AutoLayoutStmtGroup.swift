//
//  File.swift
//  
//
//  Created by Zhu Shengqi on 2019/7/19.
//

import Foundation
import UIKit

public struct AutoLayoutStmtGroup {
  
  private let _stmts: [AutoLayoutStmt]
  
  internal init(stmts: [AutoLayoutStmt]) {
    self._stmts = stmts
  }
  
  public func activate() {
    let constraints = self._stmts.map { $0._constraint }
    NSLayoutConstraint.activate(constraints)
  }
  
  public func deactivate() {
    let constraints = self._stmts.map { $0._constraint }
    NSLayoutConstraint.deactivate(constraints)
  }
  
}

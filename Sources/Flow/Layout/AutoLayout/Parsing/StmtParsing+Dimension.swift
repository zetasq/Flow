//
//  StmtParsing+Dimension.swift
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

public func <=(_ lhs: DimensionAutoLayoutExpr, _ rhs: CGFloat) -> AutoLayoutStmt {
  let parsedConstraint: NSLayoutConstraint
  let constant = (rhs - lhs.offset) / lhs.multiplier
  
  switch lhs.multiplier.sign {
  case .minus:
    parsedConstraint = lhs.anchor.constraint(greaterThanOrEqualToConstant: constant)
  case .plus:
    parsedConstraint = lhs.anchor.constraint(lessThanOrEqualToConstant: constant)
  }
  
  return AutoLayoutStmt(constraint: parsedConstraint)
}

public func <=(_ lhs: CGFloat, _ rhs: DimensionAutoLayoutExpr) -> AutoLayoutStmt {
  return rhs >= lhs
}

public func <=(_ lhs: DimensionAutoLayoutExpr, _ rhs: DimensionAutoLayoutExpr) -> AutoLayoutStmt {
  guard lhs.multiplier.sign == rhs.multiplier.sign else {
    fatalError("The multipliers of the two dimension expressions don't have the same sign")
  }
  
  let multiplier = rhs.multiplier / lhs.multiplier
  let constant = (rhs.offset - lhs.offset) / lhs.multiplier
  
  let parsedConstraint: NSLayoutConstraint
  switch lhs.multiplier.sign {
  case .minus:
    parsedConstraint = lhs.anchor.constraint(greaterThanOrEqualTo: rhs.anchor, multiplier: multiplier, constant: constant)
  case .plus:
    parsedConstraint = lhs.anchor.constraint(lessThanOrEqualTo: rhs.anchor, multiplier: multiplier, constant: constant)
  }
  
  return AutoLayoutStmt(constraint: parsedConstraint)
}

public func ==(_ lhs: DimensionAutoLayoutExpr, _ rhs: CGFloat) -> AutoLayoutStmt {
  let parsedConstraint = lhs.anchor.constraint(equalToConstant: (rhs - lhs.offset) / lhs.multiplier)
  
  return AutoLayoutStmt(constraint: parsedConstraint)
}

public func ==(_ lhs: CGFloat, _ rhs: DimensionAutoLayoutExpr) -> AutoLayoutStmt {
  return rhs == lhs
}

public func ==(_ lhs: DimensionAutoLayoutExpr, _ rhs: DimensionAutoLayoutExpr) -> AutoLayoutStmt {
  let parsedConstraint = lhs.anchor.constraint(equalTo: rhs.anchor, multiplier: rhs.multiplier / lhs.multiplier, constant: (rhs.offset - lhs.offset) / lhs.multiplier)
  
  return AutoLayoutStmt(constraint: parsedConstraint)
}

public func >=(_ lhs: DimensionAutoLayoutExpr, _ rhs: CGFloat) -> AutoLayoutStmt {
  let parsedConstraint: NSLayoutConstraint
  let constant = (rhs - lhs.offset) / lhs.multiplier
  
  switch lhs.multiplier.sign {
  case .minus:
    parsedConstraint = lhs.anchor.constraint(lessThanOrEqualToConstant: constant)
  case .plus:
    parsedConstraint = lhs.anchor.constraint(greaterThanOrEqualToConstant: constant)
  }
  
  return AutoLayoutStmt(constraint: parsedConstraint)
}

public func >=(_ lhs: CGFloat, _ rhs: DimensionAutoLayoutExpr) -> AutoLayoutStmt {
  return rhs <= lhs
}

public func >=(_ lhs: DimensionAutoLayoutExpr, _ rhs: DimensionAutoLayoutExpr) -> AutoLayoutStmt {
  guard lhs.multiplier.sign == rhs.multiplier.sign else {
    fatalError("The multipliers of the two dimension expressions don't have the same sign")
  }
  
  let multiplier = rhs.multiplier / lhs.multiplier
  let constant = (rhs.offset - lhs.offset) / lhs.multiplier
  
  let parsedConstraint: NSLayoutConstraint
  switch lhs.multiplier.sign {
  case .minus:
    parsedConstraint = lhs.anchor.constraint(lessThanOrEqualTo: rhs.anchor, multiplier: multiplier, constant: constant)
  case .plus:
    parsedConstraint = lhs.anchor.constraint(greaterThanOrEqualTo: rhs.anchor, multiplier: multiplier, constant: constant)
  }
  
  return AutoLayoutStmt(constraint: parsedConstraint)
}


//
//  StmtParsing+XAxis.swift
//  
//
//  Created by Zhu Shengqi on 2019/7/19.
//

import Foundation

public func <=(_ lhs: XAxisAutoLayoutExpr, _ rhs: XAxisAutoLayoutExpr) -> AutoLayoutStmt {
  guard lhs.multiplier == 1 && rhs.multiplier == 1 else {
    fatalError("Multipliers must be 1 when writing \(type(of: lhs)) statement")
  }
  
  let parsedConstraint = lhs.anchor.constraint(lessThanOrEqualTo: rhs.anchor, constant: rhs.offset - lhs.offset)
  
  return AutoLayoutStmt(constraint: parsedConstraint)
}

public func ==(_ lhs: XAxisAutoLayoutExpr, _ rhs: XAxisAutoLayoutExpr) -> AutoLayoutStmt {
  guard lhs.multiplier == 1 && rhs.multiplier == 1 else {
      fatalError("Multipliers must be 1 when writing \(type(of: lhs)) statement")
    }
    
    let parsedConstraint = lhs.anchor.constraint(equalTo: rhs.anchor, constant: rhs.offset - lhs.offset)
    
    return AutoLayoutStmt(constraint: parsedConstraint)
}

public func >=(_ lhs: XAxisAutoLayoutExpr, _ rhs: XAxisAutoLayoutExpr) -> AutoLayoutStmt {
  guard lhs.multiplier == 1 && rhs.multiplier == 1 else {
      fatalError("Multipliers must be 1 when writing \(type(of: lhs)) statement")
    }
    
    let parsedConstraint = lhs.anchor.constraint(greaterThanOrEqualTo: rhs.anchor, constant: rhs.offset - lhs.offset)
    
    return AutoLayoutStmt(constraint: parsedConstraint)
}

//
//  File.swift
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

public struct AutoLayoutExpr<Anchor> {
  
  internal let anchor: Anchor
  
  internal let multiplier: CGFloat
  
  internal let offset: CGFloat
  
  internal init(anchor: Anchor, multiplier: CGFloat = 1, offset: CGFloat = 0) {
    self.anchor = anchor
    self.multiplier = multiplier
    self.offset = offset
  }
  
}

public typealias XAxisAutoLayoutExpr = AutoLayoutExpr<NSLayoutXAxisAnchor>

public typealias YAxisAutoLayoutExpr = AutoLayoutExpr<NSLayoutYAxisAnchor>

public typealias DimensionAutoLayoutExpr = AutoLayoutExpr<NSLayoutDimension>


// MARK: - Multiplication
public func *(_ expr: DimensionAutoLayoutExpr, _ multiplier: CGFloat) -> DimensionAutoLayoutExpr {
  return DimensionAutoLayoutExpr(anchor: expr.anchor, multiplier: expr.multiplier * multiplier, offset: expr.offset * multiplier)
}

public func *(_ multiplier: CGFloat, _ expr: DimensionAutoLayoutExpr) -> DimensionAutoLayoutExpr {
  return expr * multiplier
}

public prefix func -(_ expr: DimensionAutoLayoutExpr) -> DimensionAutoLayoutExpr {
  return expr * -1
}

// MARK: - Addition
public func +<Anchor>(_ expr: AutoLayoutExpr<Anchor>, _ addend: CGFloat) -> AutoLayoutExpr<Anchor> {
  return AutoLayoutExpr(anchor: expr.anchor, multiplier: expr.multiplier, offset: expr.offset + addend)
}

public func +<Anchor>(_ addend: CGFloat, _ expr: AutoLayoutExpr<Anchor>) -> AutoLayoutExpr<Anchor> {
  return expr + addend
}

// MARK: - Subtraction
public func -<Anchor>(_ expr: AutoLayoutExpr<Anchor>, _ subtrahend: CGFloat) -> AutoLayoutExpr<Anchor> {
  return AutoLayoutExpr(anchor: expr.anchor, multiplier: expr.multiplier, offset: expr.offset - subtrahend)
}

public func -(_ minuend: CGFloat, _ expr: DimensionAutoLayoutExpr) -> DimensionAutoLayoutExpr {
  return -(expr - minuend)
}

// MARK: - Offset
public func -(_ lhs: XAxisAutoLayoutExpr, _ rhs: XAxisAutoLayoutExpr) -> DimensionAutoLayoutExpr {
  guard abs(lhs.multiplier) == 1 && abs(rhs.multiplier) == 1 else {
    fatalError("The multipliers of the two \(type(of: lhs)) expressions should be 1 or -1")
  }
  
  guard lhs.multiplier.sign == rhs.multiplier.sign else {
    fatalError("The multipliers of the two \(type(of: lhs)) expressions don't have the same sign")
  }
  
  guard lhs.offset == rhs.offset else {
    fatalError("The offsets of the two \(type(of: lhs)) expressions should be equal")
  }
  
  let dimensionAnchor: NSLayoutDimension
  switch lhs.multiplier.sign {
  case .minus:
    dimensionAnchor = lhs.anchor.anchorWithOffset(to: rhs.anchor)
  case .plus:
    dimensionAnchor = rhs.anchor.anchorWithOffset(to: lhs.anchor)
  }
  
  return DimensionAutoLayoutExpr(anchor: dimensionAnchor, multiplier: 1, offset: 0)
}

public func -(_ lhs: YAxisAutoLayoutExpr, _ rhs: YAxisAutoLayoutExpr) -> DimensionAutoLayoutExpr {
  guard abs(lhs.multiplier) == 1 && abs(rhs.multiplier) == 1 else {
    fatalError("The multipliers of the two \(type(of: lhs)) expressions should be 1 or -1")
  }
  
  guard lhs.multiplier.sign == rhs.multiplier.sign else {
    fatalError("The multipliers of the two \(type(of: lhs)) expressions don't have the same sign")
  }
  
  guard lhs.offset == rhs.offset else {
    fatalError("The offsets of the two \(type(of: lhs)) expressions should be equal")
  }
  
  let dimensionAnchor: NSLayoutDimension
  switch lhs.multiplier.sign {
  case .minus:
    dimensionAnchor = lhs.anchor.anchorWithOffset(to: rhs.anchor)
  case .plus:
    dimensionAnchor = rhs.anchor.anchorWithOffset(to: lhs.anchor)
  }
  
  return DimensionAutoLayoutExpr(anchor: dimensionAnchor, multiplier: 1, offset: 0)
}

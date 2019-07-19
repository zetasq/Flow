//
//  AutoLayoutAnchorAccessibleBox+AnchorExpr.swift
//  
//
//  Created by Zhu Shengqi on 2019/7/19.
//

import Foundation

extension AutoLayoutAnchorAccessibleBox {
  
  public var top: YAxisAutoLayoutExpr {
    return .init(anchor: self.accessible.topAnchor)
  }
  
  public var left: XAxisAutoLayoutExpr {
    return .init(anchor: self.accessible.leftAnchor)
  }
  
  public var bottom: YAxisAutoLayoutExpr {
    return .init(anchor: self.accessible.bottomAnchor)
  }
  
  public var right: XAxisAutoLayoutExpr {
    return .init(anchor: self.accessible.rightAnchor)
  }
  
  public var leading: XAxisAutoLayoutExpr {
    return .init(anchor: self.accessible.leadingAnchor)
  }
  
  public var trailing: XAxisAutoLayoutExpr {
    return .init(anchor: self.accessible.trailingAnchor)
  }
  
  public var centerX: XAxisAutoLayoutExpr {
    return .init(anchor: self.accessible.centerXAnchor)
  }
  
  public var centerY: YAxisAutoLayoutExpr {
    return .init(anchor: self.accessible.centerYAnchor)
  }
  
  public var firstBaseline: YAxisAutoLayoutExpr {
    return .init(anchor: self.accessible.firstBaselineAnchor)
  }
  
  public var lastBaseline: YAxisAutoLayoutExpr {
    return .init(anchor: self.accessible.lastBaselineAnchor)
  }
  
  public var width: DimensionAutoLayoutExpr {
    return .init(anchor: self.accessible.widthAnchor)
  }
  
  public var height: DimensionAutoLayoutExpr {
    return .init(anchor: self.accessible.heightAnchor)
  }
  
}

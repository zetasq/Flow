//
//  AutoLayoutAnchorAccessibleBox.swift
//  
//
//  Created by Zhu Shengqi on 2019/7/19.
//

import Foundation

@MainActor
public struct AutoLayoutAnchorAccessibleBox<Accessible: AutoLayoutAnchorAccessible> {
  
  internal let accessible: Accessible
  
  internal init(_ accessible: Accessible) {
    self.accessible = accessible
  }
  
}

extension AutoLayoutAnchorAccessible {
  
  public var anchor: AutoLayoutAnchorAccessibleBox<Self> {
    return AutoLayoutAnchorAccessibleBox(self)
  }
  
}



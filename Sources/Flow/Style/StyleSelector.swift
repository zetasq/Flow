//
//  StyleSelector.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/6.
//

import Foundation

public struct StyleSelector<TargetElement: Stylable> {
  
  public var targetCategory: StyleSemanticCategory?
  
  public var ancestors: [(elementType: Stylable.Type, elementCategory: StyleSemanticCategory?)]
  
  public init(targetCategory: StyleSemanticCategory? = nil, ancestors: [(elementType: Stylable.Type, elementCategory: StyleSemanticCategory?)] = []) {
    self.targetCategory = targetCategory
    self.ancestors = ancestors
  }
  
}

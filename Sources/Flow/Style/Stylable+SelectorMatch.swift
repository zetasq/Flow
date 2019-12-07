//
//  Stylable+SelectorMatch.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/7.
//

import Foundation
import Concrete

extension Stylable {
  
  public func matchesSelector<TargetElement>(_ selector: StyleSelector<TargetElement>, scopeElement: Stylable) -> Bool {
    guard self.matches(elementType: TargetElement.self, semanticCategory: selector.targetCategory) else {
      return false
    }
    
    guard !selector.ancestors.isEmpty else {
      return true
    }
    
    guard scopeElement !== self else {
      return false
    }
    
    let ancestors = selector.ancestors
    var index = ancestors.startIndex
    var stylableWalker = self.parentStylable
    
    while let nextStylable = stylableWalker, index != ancestors.endIndex {
      let ancestorToMatch = ancestors[index]
      
      if nextStylable.matches(elementType: ancestorToMatch.elementType, semanticCategory: ancestorToMatch.elementCategory) {
        index = ancestors.index(after: index)
      }
      
      if stylableWalker === scopeElement {
        break
      }
      
      stylableWalker = stylableWalker?.parentStylable
    }
    
    return index == ancestors.endIndex
  }
  
  internal func matches(elementType: Stylable.Type, semanticCategory: StyleSemanticCategory?) -> Bool {
    guard SwiftRuntime.objectIsKindOf(self, baseType: elementType) else {
      return false
    }

    return semanticCategory == nil || semanticCategory == self.styleSemanticCategory
  }
  
}

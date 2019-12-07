//
//  File.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/7.
//

import Foundation

extension Stylable {
  
  public func applyStyleRules() {
    var scopeContainer: Stylable? = self
    
    while let container = scopeContainer {
      container._withEachBoundScope { scope in
        for rule in scope.rules where rule.matchesElement(self, scopeElement: container) {
          rule.apply(to: self)
        }
      }
      scopeContainer = scopeContainer?.parentStylable
    }
  }
  
  public func applyStyleRulesRecursively() {
    self.applyStyleRules()
    
    for childStylable in self.childStylables {
      childStylable.applyStyleRulesRecursively()
    }
  }
  
}

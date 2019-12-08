//
//  Stylable+Scope.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/7.
//

import Foundation
import Concrete

internal final class _StyleScopeTable {
  
  internal private(set) var nameToScopeMapping: [String: StyleScope] = [:]
  
  internal init() {}
  
  internal func withScope(named scopeName: String, _ block: (_ scope: StyleScope) -> Void) {
    let scope: StyleScope
    
    if let existingScope = nameToScopeMapping[scopeName] {
      scope = existingScope
    } else {
      let newScope = StyleScope(name: scopeName)
      nameToScopeMapping[scopeName] = newScope
      scope = newScope
    }
    
    block(scope)
  }
}


private var boundScopeTableKey = "boundScopeTableKey"

extension Stylable {
  
  public func withStyleScope(named scopeName: String, @StyleRulesBuilder _ block: () -> [AbstractStyleRule]) {
    // There is no + (void)load method in Swift, so we use the once token pattern here to do the logic injection into UIKit.
    _ = UIKitStyleAutomationOnceToken
    
    let scopeTable: _StyleScopeTable
    
    if let existingTable = objc_getAssociatedObject(self, &boundScopeTableKey) as? _StyleScopeTable {
      scopeTable = existingTable
    } else {
      let newTable = _StyleScopeTable()
      objc_setAssociatedObject(self, &boundScopeTableKey, newTable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      scopeTable = newTable
    }
    
    scopeTable.withScope(named: scopeName) { (scope) in
      scope.removeAllRules()
      let rules = block()
      scope.addRules(rules)
    }
    
    if self.needsApplyStyleRulesRecursivelyImmediatelyForRulesChange {
      self.applyStyleRulesRecursively()
    }
  }
  
  internal func _withEachBoundScope(_ block: (_ scope: StyleScope) -> Void) {
    guard let table = objc_getAssociatedObject(self, &boundScopeTableKey) as? _StyleScopeTable else {
      return
    }
    
    for (_, scope) in table.nameToScopeMapping {
      block(scope)
    }
  }
  
}

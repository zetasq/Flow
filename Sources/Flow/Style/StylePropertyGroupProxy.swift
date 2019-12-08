//
//  StylePropertyGroupProxy.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/7.
//

import Foundation

@dynamicMemberLookup
public final class StylePropertyGroupProxy<StylableElement: Stylable> {
  
  public private(set) var propertyTable: [PartialKeyPath<StylableElement>: PartialStyleProperty<StylableElement>] = [:]
  
  public init() {}
  
  public subscript<Value>(dynamicMember member: ReferenceWritableKeyPath<StylableElement, Value>) -> Value? {
    get {
      return (propertyTable[member] as? StyleProperty<StylableElement, Value>)?.propertyValue
    }
    set(newValue) {
      if let value = newValue {
        propertyTable[member] = StyleProperty(propertyKeyPath: member, propertyValue: value)
      } else {
        propertyTable[member] = nil
      }
    }
  }
  
}

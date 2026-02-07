//
//  StyleRule.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/6.
//

import Foundation

@MainActor
public class AbstractStyleRule {
  
  public let elementType: Stylable.Type
  
  public init(elementType: Stylable.Type) {
    self.elementType = elementType
  }
  
  public func matchesElement(_ element: Stylable, scopeElement: Stylable) -> Bool {
    fatalError("\(#function) should be implemented by subclass")
  }
  
  public func apply(to element: Stylable) {
    fatalError("\(#function) should be implemented by subclass")
  }
  
}

@MainActor
public final class StyleRule<StylableElement: Stylable>: AbstractStyleRule {
  
  public let selector: StyleSelector<StylableElement>
  
  private var _stylePropertyTable: [PartialKeyPath<StylableElement>: PartialStyleProperty<StylableElement>]
  
  public init(selector: StyleSelector<StylableElement>, stylePropertyTable: [PartialKeyPath<StylableElement>: PartialStyleProperty<StylableElement>] = [:]) {
    self.selector = selector
    self._stylePropertyTable = stylePropertyTable
    
    super.init(elementType: StylableElement.self)
  }
  
  public func addStyleProperty<Value>(_ styleProperty: StyleProperty<StylableElement, Value>) {
    _stylePropertyTable[styleProperty.propertyKeyPath] = styleProperty
  }
  
  public func addStyleProperties(_ styleProperties: [PartialStyleProperty<StylableElement>]) {
    for property in styleProperties {
      _stylePropertyTable[property.partialPropertyKeyPath] = property
    }
  }
  
  public override func matchesElement(_ element: Stylable, scopeElement: Stylable) -> Bool {
    return element.matchesSelector(self.selector, scopeElement: scopeElement)
  }
  
  public override func apply(to element: Stylable) {
    let castedElement = element as! StylableElement
    
    for (_, property) in _stylePropertyTable {
      property.apply(to: castedElement)
    }
  }
}

//
//  StyleRule.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/6.
//

import Foundation

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

public final class StyleRule<StylableElement: Stylable>: AbstractStyleRule {
  
  public let selector: StyleSelector<StylableElement>
  
  private var _stylePropertyTable: [PartialKeyPath<StylableElement>: PartialStyleProperty<StylableElement>] = [:]
  
  public init(selector: StyleSelector<StylableElement>){
    self.selector = selector
    
    super.init(elementType: StylableElement.self)
  }
  
  public func addStyleProperty<Value>(_ styleProperty: StyleProperty<StylableElement, Value>) {
    _stylePropertyTable[styleProperty.propertyKeyPath] = styleProperty
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

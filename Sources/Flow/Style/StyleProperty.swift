//
//  StyleProperty.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/6.
//

import Foundation

public class PartialStyleProperty<StylableElement> {
  
  public func apply(to element: StylableElement) {
    fatalError("\(#function) should be implemented by subclass")
  }
  
}

public final class StyleProperty<StylableElement, Value>: PartialStyleProperty<StylableElement> {
  
  public let propertyKeyPath: ReferenceWritableKeyPath<StylableElement, Value>
  
  public let propertyValue: Value
  
  public init(propertyKeyPath: ReferenceWritableKeyPath<StylableElement, Value>, propertyValue: Value) {
    self.propertyKeyPath = propertyKeyPath
    self.propertyValue = propertyValue
  }
  
  public override func apply(to element: StylableElement) {
    element[keyPath: propertyKeyPath] = propertyValue
  }
  
}

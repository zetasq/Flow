//
//  StyleScope.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/6.
//

import Foundation

public final class StyleScope {
  
  public let name: String
  
  // Can we use more complicated data structures to speed up rules searching?
  // I have tried [ObjectIdentifier(elementType): [AbstractStyleRule]], but this has an issue about class inheritence.
  public private(set) var rules: [AbstractStyleRule] = []
  
  public init(name: String) {
    self.name = name
  }

  public func addRules(_ newRules: [AbstractStyleRule]) {
    rules.append(contentsOf: newRules)
  }
  
  public func removeAllRules() {
    rules.removeAll()
  }

}

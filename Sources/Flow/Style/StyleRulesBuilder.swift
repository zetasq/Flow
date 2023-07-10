//
//  StyleRulesBuilder.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/7.
//

import Foundation

@resultBuilder
public struct StyleRulesBuilder {
  
  public static func buildBlock(_ rules: AbstractStyleRule...) -> [AbstractStyleRule] {
    return rules
  }
  
}

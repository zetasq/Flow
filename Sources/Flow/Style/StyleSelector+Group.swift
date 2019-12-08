//
//  StyleSelector+Group.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/7.
//

import Foundation

extension StyleSelector {
  
  public static func group(targetCategory: StyleSemanticCategory? = nil, ancestors: [(elementType: Stylable.Type, elementCategory: StyleSemanticCategory?)] = [], _ block: (_ proxy: StylePropertyGroupProxy<TargetElement>) -> Void) -> StyleRule<TargetElement> {
    let selector = StyleSelector<TargetElement>(targetCategory: targetCategory, ancestors: ancestors)
    
    let proxy = StylePropertyGroupProxy<TargetElement>()
    block(proxy)
    
    let rule = StyleRule(selector: selector, stylePropertyTable: proxy.propertyTable)
    return rule
  }
  
}

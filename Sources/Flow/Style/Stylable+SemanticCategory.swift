//
//  Stylable+SemanticCategory.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/7.
//

import Foundation

private var boundStyleSemanticCategoryKey = "boundStyleSemanticCategoryKey"

extension Stylable {
  
  public var styleSemanticCategory: StyleSemanticCategory? {
    get {
      guard let category = objc_getAssociatedObject(self, &boundStyleSemanticCategoryKey) as? StyleSemanticCategory else {
        return nil
      }
      
      return category
    }
    set {
      guard let category = newValue else {
        objc_setAssociatedObject(self, &boundStyleSemanticCategoryKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return
      }
      
      objc_setAssociatedObject(self, &boundStyleSemanticCategoryKey, category, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
}

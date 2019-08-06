//
//  UIViewController+PageItem.swift
//  
//
//  Created by Zhu Shengqi on 2019/8/4.
//

import Foundation
import UIKit

extension UIViewController {
  
  public final class PageItem {
    
    public var title: String?
    
    public init() {
      
      
    }
    
  }
  
  private static var pageItemKey = "pageItemKey"
  
  public final var pageItem: PageItem {
    if let existingItem = objc_getAssociatedObject(self, &Self.pageItemKey) as? PageItem {
      return existingItem
    } else {
      let newItem = PageItem()
      objc_setAssociatedObject(self, &Self.pageItemKey, newItem, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return newItem
    }
  }
  
}

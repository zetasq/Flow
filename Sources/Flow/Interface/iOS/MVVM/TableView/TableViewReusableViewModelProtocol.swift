//
//  TableViewReusableViewModelProtocol.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/9/2.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation
import Concrete

public protocol TableViewReusableViewModelProtocol: AnyObject {}


private var boundTableViewSectionKey = "com.zetasq.Arsenal.boundTableViewSectionKey"

extension TableViewReusableViewModelProtocol {
  
  internal var boundTableViewSection: TableViewSection? {
    get {
      return (objc_getAssociatedObject(self, &boundTableViewSectionKey) as? WeakObjectBox<TableViewSection>)?.object
    }
    set {
      if let section = newValue {
        let container = WeakObjectBox(object: section)
        objc_setAssociatedObject(self, &boundTableViewSectionKey, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      } else {
        objc_setAssociatedObject(self, &boundTableViewSectionKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
    }
  }
  
  public func updateLayout(animated: Bool) {
    boundTableViewSection?.updateLayout(for: self, animated: animated)
  }
  
}

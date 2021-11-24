//
//  CollectionViewReusableViewModelProtocol.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/5.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import Foundation
import Concrete

public protocol CollectionViewReusableViewModelProtocol: AnyObject {}


private var boundCollectionViewSectionKey = "com.zetasq.Arsenal.boundCollectionViewSectionKey"

extension CollectionViewReusableViewModelProtocol {
  
  internal var boundCollectionViewSection: CollectionViewSection? {
    get {
      return (objc_getAssociatedObject(self, &boundCollectionViewSectionKey) as? WeakObjectBox<CollectionViewSection>)?.object
    }
    set {
      if let section = newValue {
        let container = WeakObjectBox(object: section)
        objc_setAssociatedObject(self, &boundCollectionViewSectionKey, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      } else {
        objc_setAssociatedObject(self, &boundCollectionViewSectionKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
    }
  }
  
//  public func updateLayout(animated: Bool) {
//    boundTableViewSection?.updateLayout(for: self, animated: animated)
//  }
//  
}

#endif

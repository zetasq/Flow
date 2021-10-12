//
//  ViewModelViewMappable.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 12/7/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public protocol ViewModelViewMappable: AnyObject {}

private var viewModelToViewMappingKey = "com.zetasq.Arsenal.viewModelToViewMappingKey"

extension ViewModelViewMappable {
  
  private var viewModelToViewMapping: ViewModelToViewMapping {
    if let existingMapping = objc_getAssociatedObject(self, &viewModelToViewMappingKey) as? ViewModelToViewMapping {
      return existingMapping
    } else {
      let newMapping = ViewModelToViewMapping()
      objc_setAssociatedObject(self, &viewModelToViewMappingKey, newMapping, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return newMapping
    }
  }
  
  internal func _mvvm_registerViewClassToMapping<T: ViewModelViewProtocol>(_ viewClass: T.Type) {
    viewModelToViewMapping.registerViewClass(viewClass)
  }
  
  internal func _mvvm_registeredViewClassInMapping(forViewModelClass viewModelClass: Any.Type) -> AnyClass? {
    return viewModelToViewMapping.registeredViewClass(forViewModelClass: viewModelClass)
  }
  
}

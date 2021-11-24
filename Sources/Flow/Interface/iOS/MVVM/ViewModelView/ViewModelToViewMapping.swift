//
//  ViewModelToViewMapping.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/7/15.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import Foundation

internal final class ViewModelToViewMapping {
  
  private var table: [String: AnyClass] = [:]
  
  internal func registerViewClass<T: ViewModelViewProtocol>(_ viewClass: T.Type) {
    let viewModelTypeName = String(reflecting: viewClass.ViewModel.self)
    table[viewModelTypeName] = viewClass
  }
  
  internal func registeredViewClass(forViewModelClass viewModelClass: Any.Type) -> AnyClass? {
    let viewModelTypeName = String(reflecting: viewModelClass)
    return table[viewModelTypeName]
  }
  
}

#endif

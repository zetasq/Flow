//
//  UIView+ViewModel.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 12/7/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import UIKit

extension UIView {
  
  private static var associatedViewModelKey = "com.zetasq.Arsenal.UIView.associatedViewModelKey"
  
  internal final var _associatedViewModel: Any? {
    get {
      assert(Thread.isMainThread)
      return objc_getAssociatedObject(self, &UIView.associatedViewModelKey)
    }
    set {
      assert(Thread.isMainThread)
      objc_setAssociatedObject(self, &UIView.associatedViewModelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      
      if let _ = newValue, let viewModelViewObj = self as? ViewModelViewOverridenProtocol {
        viewModelViewObj.viewModelDidUpdate()
      }
    }
  }

}

#endif

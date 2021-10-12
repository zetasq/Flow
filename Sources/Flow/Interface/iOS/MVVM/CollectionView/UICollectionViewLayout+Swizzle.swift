//
//  UICollectionViewLayout+Swizzle.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/13.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import UIKit

extension UICollectionViewLayout {
  
  internal static let swizzleToken: Void = {
    
    do {
      let originMethod = class_getInstanceMethod(UICollectionViewLayout.self, #selector(UICollectionViewLayout.prepare as (UICollectionViewLayout) -> () -> Void))!
      
      let targetMethod = class_getInstanceMethod(UICollectionViewLayout.self, #selector(UICollectionViewLayout._arsenal_swizzled_prepare))!
      
      method_exchangeImplementations(originMethod, targetMethod)
    }

  }()
  
  @objc
  dynamic
  private func _arsenal_swizzled_prepare() {
    _arsenal_swizzled_prepare()
    
    (self.collectionView?.delegate as? CollectionViewLayoutAugmentDelegate)?.collectionViewLayoutDidPrepare(self)
  }

}

#endif

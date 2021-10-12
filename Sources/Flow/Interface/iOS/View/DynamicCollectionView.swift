//
//  DynamicCollectionView.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/5.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import UIKit

open class DynamicCollectionView: UICollectionView {
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    
    if bounds.size != intrinsicContentSize {
      invalidateIntrinsicContentSize()
    }
  }
  
  open override var intrinsicContentSize: CGSize {
    return self.contentSize
  }
}

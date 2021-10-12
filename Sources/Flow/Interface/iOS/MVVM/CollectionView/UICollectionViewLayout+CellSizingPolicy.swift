//
//  UICollectionViewLayout+CellSizingPolicy.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/13.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import UIKit

extension UICollectionViewLayout {
  
  public enum CellSizingPolicy {
    
    case dynamic
    
    case manual(itemSize: CGSize)
    
  }
  
}

#endif

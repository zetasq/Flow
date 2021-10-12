//
//  CollectionViewCellSizingProtocol.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/11.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

public enum CollectionViewCellSize {
  
  case dynamic
  
  case manual(CollectionViewReusableViewLayoutValue<CGSize>)
  
}

public protocol CollectionViewCellSizingProtocol {
  
  static var cellSize: CollectionViewCellSize { get }

}

#endif

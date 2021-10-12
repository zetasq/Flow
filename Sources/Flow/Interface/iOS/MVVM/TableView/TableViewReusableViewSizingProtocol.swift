//
//  TableViewReusableViewSizingProtocol.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/9/2.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import UIKit

public enum TableViewReusableViewHeight {
  
  case dynamic
  
  case fixed(value: CGFloat)
  
}

public protocol TableViewReusableViewSizingProtocol {
  
  static func tableViewReusableViewHeight(forTableViewBounds tableViewBounds: CGRect) -> TableViewReusableViewHeight
  
}

#endif

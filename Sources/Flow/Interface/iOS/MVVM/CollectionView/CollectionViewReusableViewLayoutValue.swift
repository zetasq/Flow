//
//  CollectionViewReusableViewLayoutValue.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/13.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public enum CollectionViewReusableViewLayoutValue<T> {
  
  case inheritFromSection
  
  case fixed(T)
  
}

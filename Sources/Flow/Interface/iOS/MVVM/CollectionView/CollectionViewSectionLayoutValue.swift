//
//  CollectionViewSectionLayoutValue.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/13.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public enum CollectionViewSectionLayoutValue<T> {
  
  case inheritFromLayout
  
  case fixed(T)
  
}

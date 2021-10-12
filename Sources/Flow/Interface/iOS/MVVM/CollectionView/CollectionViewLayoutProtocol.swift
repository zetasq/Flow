//
//  CollectionViewLayoutProtocol.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/4.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public protocol CollectionViewLayoutProtocol: AnyObject {
  
  associatedtype ViewModelSectionType: CollectionViewSection
  
}

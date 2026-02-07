//
//  CollectionViewLayoutAugmentDelegate.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/14.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import UIKit

@MainActor
public protocol CollectionViewLayoutAugmentDelegate: AnyObject {
  
  func collectionViewLayoutDidPrepare(_ layout: UICollectionViewLayout)
  
}

#endif

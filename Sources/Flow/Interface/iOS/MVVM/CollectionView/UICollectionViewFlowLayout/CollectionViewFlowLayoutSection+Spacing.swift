//
//  CollectionViewFlowLayoutSection+Spacing.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/15.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

extension CollectionViewFlowLayoutSection {
  
  public struct Spacing {
    
    public var itemSize: CollectionViewSectionLayoutValue<CGSize> = .inheritFromLayout
    
    public var sectionInset: CollectionViewSectionLayoutValue<UIEdgeInsets> = .inheritFromLayout
    
    public var minimumLineSpacing: CollectionViewSectionLayoutValue<CGFloat> = .inheritFromLayout
    
    public var minimumInteritemSpacing: CollectionViewSectionLayoutValue<CGFloat> = .inheritFromLayout
    
    public var headerReferenceSize: CollectionViewSectionLayoutValue<CGSize> = .inheritFromLayout
    
    public var footerReferenceSize: CollectionViewSectionLayoutValue<CGSize> = .inheritFromLayout
    
  }
  
}

#endif

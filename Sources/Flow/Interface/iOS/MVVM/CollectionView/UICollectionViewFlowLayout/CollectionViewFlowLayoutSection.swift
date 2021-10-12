//
//  CollectionViewFlowLayoutSection.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/4.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

open class CollectionViewFlowLayoutSection: CollectionViewSection {
  
  public final var spacing = Spacing()
  
  public final var sectionHeaderViewModel: CollectionViewSupplementaryViewModelProtocol? {
    return supplementaryViewModel(ofKind: UICollectionView.elementKindSectionHeader)
  }
  
  public final func setSectionHeaderViewModel(_ sectionHeaderViewModel: CollectionViewSupplementaryViewModelProtocol?, animated: Bool) {
    setSupplementaryViewModel(sectionHeaderViewModel, ofKind: UICollectionView.elementKindSectionHeader, animated: animated)
  }
  
  public final var sectionFooterViewModel: CollectionViewSupplementaryViewModelProtocol? {
    return supplementaryViewModel(ofKind: UICollectionView.elementKindSectionFooter)
  }
  
  public final func setSectionFooterViewModel(_ sectionFooterViewModel: CollectionViewSupplementaryViewModelProtocol?, animated: Bool) {
    setSupplementaryViewModel(sectionFooterViewModel, ofKind: UICollectionView.elementKindSectionFooter, animated: animated)
  }

}

#endif

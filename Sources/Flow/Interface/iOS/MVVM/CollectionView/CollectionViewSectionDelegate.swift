//
//  CollectionViewSectionDelegate.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/5.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import Foundation

@MainActor
public protocol CollectionViewSectionDelegate: AnyObject {
  
  // MARK: - Insert
  func collectionViewSection(_ section: CollectionViewSection,
                             requestInsertingAtIndices itemIndices: [Int],
                             dataChange: @escaping () -> Void,
                             animated: Bool)

  // MARK: - Reload
  func collectionViewSection(_ section: CollectionViewSection,
                        requestReloadingWholeSectionWithChange dataChange: @escaping () -> Void,
                        animated: Bool)

  func collectionViewSection(_ section: CollectionViewSection,
                             requestUpdatingSupplementaryViewsWithChange dataChange: @escaping () -> Void,
                             animated: Bool)
}

#endif

//
//  UICollectionView+Reuse.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 17/03/2017.
//  Copyright © 2017 Zhu Shengqi. All rights reserved.
//

import UIKit

extension UICollectionReusableView: Reusable {}

public extension UICollectionView {
  // MARK: - Register
  func registerClassForCell<T: UICollectionViewCell>(type: T.Type) {
    register(type, forCellWithReuseIdentifier: T.reuseIdentifier)
  }
  
  func registerClassForSupplementaryView<T: UICollectionReusableView>(type: T.Type, ofKind kind: String) {
    register(type, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
  }

  // MARK: - Dequeue
  func dequeueReusableCell<T: UICollectionViewCell>(type: T.Type, for indexPath: IndexPath) -> T {
    return dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
  }
  
  func dequeueOpaqueReusableCell(type: AnyClass, for indexPath: IndexPath) -> UICollectionViewCell {
    return dequeueReusableCell(withReuseIdentifier: (type as! UICollectionViewCell.Type).reuseIdentifier, for: indexPath)
  }
  
  func dequeueReusableSupplementaryView<T: UICollectionReusableView>(type: T.Type, ofKind kind: String, for indexPath: IndexPath) -> T {
    return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
  }
  
  func dequeueOpaqueReusableSupplementaryView(type: AnyClass, ofKind kind: String, for indexPath: IndexPath) -> UICollectionReusableView {
    return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: (type as! UICollectionReusableView.Type).reuseIdentifier, for: indexPath)
  }
}

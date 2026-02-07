//
//  CollectionViewCellModelProtocol.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/4.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

public protocol CollectionViewCellModelProtocol: CollectionViewReusableViewModelProtocol {
  
  var shouldHighlight: Bool { get }
  
  var shouldSelect: Bool { get }
  
  var autoDeselect: Bool { get }
  
  var canMove: Bool { get }
  
  var canBeMovedTo: Bool { get }
  
  var supportedMenuActions: [Selector] { get }
  
}

@MainActor
private var collectionViewCellModelSelectHandlerKey: Void?

@MainActor
private var collectionViewCellModelMenuActionHandlerKey: Void?

@MainActor
extension CollectionViewCellModelProtocol {
  
  // MARK: - Default protocol implementation
  public var shouldHighlight: Bool {
    return true
  }
  
  public var shouldSelect: Bool {
    return true
  }
  
  public var autoDeselect: Bool {
    return true
  }
  
  public var canMove: Bool {
    return false
  }
  
  public var canBeMovedTo: Bool {
    return true
  }
  
  public var supportedMenuActions: [Selector] {
    return []
  }
  
  // MARK: - Action
  public var selectHandler: ((CollectionViewCellModelProtocol, UICollectionViewCell) -> Void)? {
    get {
      return objc_getAssociatedObject(self, &collectionViewCellModelSelectHandlerKey) as? ((CollectionViewCellModelProtocol, UICollectionViewCell) -> Void)
    }
    set {
      objc_setAssociatedObject(self, &collectionViewCellModelSelectHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  public var menuActionHandler: ((CollectionViewCellModelProtocol, Selector, UICollectionViewCell) -> Void)? {
    get {
      return objc_getAssociatedObject(self, &collectionViewCellModelMenuActionHandlerKey) as? ((CollectionViewCellModelProtocol, Selector, UICollectionViewCell) -> Void)
    }
    set {
      objc_setAssociatedObject(self, &collectionViewCellModelMenuActionHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
}

#endif

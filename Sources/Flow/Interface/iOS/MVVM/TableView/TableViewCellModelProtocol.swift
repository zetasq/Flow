//
//  TableViewCellModelProtocol.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/9/2.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

public protocol TableViewCellModelProtocol: TableViewReusableViewModelProtocol {
  
  var shouldHighlight: Bool { get }
  
  var shouldSelect: Bool { get }
  
  var autoDeselect: Bool { get }

  var canEdit: Bool { get }
  
  var editingStyle: UITableViewCell.EditingStyle { get }
  
  var canMove: Bool { get }
  
  var canBeMovedTo: Bool { get }
  
  var supportedMenuActions: [Selector] { get }
  
}

@MainActor
private var tableViewCellModelSelectHandlerKey: Void?

@MainActor
private var tableViewCellModelAccessoryTapHandlerKey: Void?

@MainActor
private var tableViewCellModelEditingStyleCommittingHandlerKey: Void?

@MainActor
private var tableViewCellModelLeadingSwipeActionsConfigurationKey: Void?

@MainActor
private var tableViewCellModelTrailingSwipeActionsConfigurationKey: Void?

@MainActor
private var tableViewCellModelMenuActionHandlerKey: Void?

extension TableViewCellModelProtocol {
  
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
  
  public var canEdit: Bool {
    return true
  }
  
  public var editingStyle: UITableViewCell.EditingStyle {
    return .delete
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
  public var selectHandler: ((TableViewCellModelProtocol, UITableViewCell) -> Void)? {
    get {
      return objc_getAssociatedObject(self, &tableViewCellModelSelectHandlerKey) as? ((TableViewCellModelProtocol, UITableViewCell) -> Void)
    }
    set {
      objc_setAssociatedObject(self, &tableViewCellModelSelectHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  public var accessoryTapHandler: ((TableViewCellModelProtocol, UITableViewCell) -> Void)? {
    get {
      return objc_getAssociatedObject(self, &tableViewCellModelAccessoryTapHandlerKey) as? ((TableViewCellModelProtocol, UITableViewCell) -> Void)
    }
    set {
      objc_setAssociatedObject(self, &tableViewCellModelAccessoryTapHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  public var editingStyleCommittingHandler: ((TableViewCellModelProtocol, UITableViewCell.EditingStyle, UITableViewCell) -> Void)? {
    get {
      return objc_getAssociatedObject(self, &tableViewCellModelEditingStyleCommittingHandlerKey) as? ((TableViewCellModelProtocol, UITableViewCell.EditingStyle, UITableViewCell) -> Void)
    }
    set {
      objc_setAssociatedObject(self, &tableViewCellModelEditingStyleCommittingHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  public var leadingSwipeActionsConfiguration: UISwipeActionsConfiguration? {
    get {
      return objc_getAssociatedObject(self, &tableViewCellModelLeadingSwipeActionsConfigurationKey) as? UISwipeActionsConfiguration
    }
    set {
      objc_setAssociatedObject(self, &tableViewCellModelLeadingSwipeActionsConfigurationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  public var trailingSwipeActionsConfiguration: UISwipeActionsConfiguration? {
    get {
      return objc_getAssociatedObject(self, &tableViewCellModelTrailingSwipeActionsConfigurationKey) as? UISwipeActionsConfiguration
    }
    set {
      objc_setAssociatedObject(self, &tableViewCellModelTrailingSwipeActionsConfigurationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  public var menuActionHandler: ((TableViewCellModelProtocol, Selector, UITableViewCell) -> Void)? {
    get {
      return objc_getAssociatedObject(self, &tableViewCellModelMenuActionHandlerKey) as? ((TableViewCellModelProtocol, Selector, UITableViewCell) -> Void)
    }
    set {
      objc_setAssociatedObject(self, &tableViewCellModelMenuActionHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  // MARK: - Convenience methods into TableViewSection
  public func reload(animated: Bool) {
    boundTableViewSection?.reloadViewModel(self, animated: animated)
  }
  
  public func remove(animated: Bool) {
    boundTableViewSection?.removeViewModel(self, animated: animated)
  }
  
  public func select(animated: Bool, scrollPosition: UITableView.ScrollPosition) {
    boundTableViewSection?.selectViewModel(self, animated: animated, scrollPosition: scrollPosition)
  }
  
  public func deselect(animated: Bool) {
    boundTableViewSection?.deselectViewModel(self, animated: animated)
  }
  
  public func scrollTo(at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
    boundTableViewSection?.scrollToViewModel(self, at: scrollPosition, animated: animated)
  }
  
}

#endif

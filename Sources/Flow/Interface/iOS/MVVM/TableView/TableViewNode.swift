//
//  TableViewController.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/7/15.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

public final class TableViewNode<TableViewType: UITableView>: NSObject, ViewModelViewMappable, UITableViewDataSource, UITableViewDelegate {
  
  // MARK: - Properties
  public let tableView: TableViewType
  
  public private(set) var viewModelSections: [TableViewSection] = []
  
  // MARK: Init & deinit
  public init(frame: CGRect, style: UITableView.Style) {
    self.tableView = TableViewType(frame: frame, style: style)
    
    super.init()
    
    self.tableView.dataSource = self
    self.tableView.delegate = self
    
    // We should call reloadData here, otherwise the future insertion will not be correct
    self.tableView.reloadData()
  }
  
  // MARK: - Public API
  public func registerClassForCell<T: TableViewCellProtocol>(_ viewClass: T.Type) {
    _mvvm_registerViewClassToMapping(viewClass)
    tableView.registerClassForCell(type: viewClass)
  }
  
  public func registerClassForHeaderFooterView<T: TableViewHeaderFooterViewProtocol>(_ viewClass: T.Type) {
    _mvvm_registerViewClassToMapping(viewClass)
    tableView.registerClassForHeaderFooterView(type: viewClass)
  }
  
  public func reloadContent() {
    // TODO: Add loader support
    tableView.reloadData()
  }
  
  public func addViewModelSection(_ section: TableViewSection, animated: Bool) {
    addViewModelSections([section], animated: animated)
  }
  
  public func addViewModelSections(_ sections: [TableViewSection], animated: Bool) {
    let updateBlock = {
      self.tableView.performBatchUpdates({
        let indices = IndexSet(integersIn: self.viewModelSections.count..<self.viewModelSections.count + sections.count)
        
        self.viewModelSections.append(contentsOf: sections)
        for section in sections {
          section.delegate = self
        }
        
        self.tableView.insertSections(indices, with: .automatic)
      }, completion: nil)
    }
    
    if animated {
      updateBlock()
    } else {
      UIView.performWithoutAnimation {
        updateBlock()
      }
    }
  }
  
  public func removeSection(_ section: TableViewSection, animated: Bool) {
    removeSections([section], animated: animated)
  }
  
  public func removeSections(_ sections: [TableViewSection], animated: Bool) {
    let updateBlock = {
      self.tableView.performBatchUpdates({
        var indicesToDelete = IndexSet()
        
        for section in sections {
          guard let index = self.viewModelSections.firstIndex(where: { $0 === section }) else {
            continue
          }
          
          indicesToDelete.insert(index)
        }
        
        for section in sections {
          guard let index = self.viewModelSections.firstIndex(where: { $0 === section }) else {
            continue
          }
          
          section.delegate = nil
          self.viewModelSections.remove(at: index)
        }
        
        self.tableView.deleteSections(indicesToDelete, with: .automatic)
      }, completion: nil)
    }
    
    if animated {
      updateBlock()
    } else {
      UIView.performWithoutAnimation {
        updateBlock()
      }
    }
  }
  
  // TODO: like UIView's insert/bring methods, we can use tableView's insert and move methods to do the same things

  public func deselectAllRows(animated: Bool) {
    tableView.selectRow(at: nil, animated: animated, scrollPosition: .none)
  }
  
  // MARK: - UITableViewDataSource
  public func numberOfSections(in tableView: UITableView) -> Int {
    return viewModelSections.count
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModelSections[section].viewModels.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.row]
    
    let viewModelClass = type(of: viewModel)
    guard let viewClass = _mvvm_registeredViewClassInMapping(forViewModelClass: viewModelClass) else {
      fatalError("Cannot find paired view class for viewModel: \(viewModel)")
    }
    
    let cell = tableView.dequeueOpaqueReusableCell(type: viewClass.self, for: indexPath)
    
    cell._associatedViewModel = viewModel
    
    return cell
  }
  
  public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.row]
    
    return viewModel.canEdit
  }
  
  public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.row]
    
    return viewModel.canMove
  }
  
  public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    guard sourceIndexPath != destinationIndexPath else { return }
    
    tableView.deselectRow(at: destinationIndexPath, animated: true) // prevent cell's seperator dissappear, but this will fix the iOS bug in most cases (but not all)
    
    let sourceSection = viewModelSections[sourceIndexPath.section]
    let viewModel = sourceSection.viewModels.remove(at: sourceIndexPath.row)
    
    let destinationSection = viewModelSections[destinationIndexPath.section]
    destinationSection.viewModels.insert(viewModel, at: destinationIndexPath.row)
    
    viewModel.boundTableViewSection = destinationSection
  }
  
  // MARK: - UITableViewDelegate
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard let viewModel = viewModelSections[section].headerViewModel else {
      return 0
    }
    
    let viewModelClass = type(of: viewModel)
    guard let viewClass = _mvvm_registeredViewClassInMapping(forViewModelClass: viewModelClass) else {
      fatalError("Cannot find paired view class for viewModel: \(viewModel)")
    }
    
    guard let viewSizingClass = viewClass as? TableViewReusableViewSizingProtocol.Type else {
      fatalError("\(viewClass) does not conform to \(TableViewReusableViewSizingProtocol.self)")
    }
    
    switch viewSizingClass.tableViewReusableViewHeight(forTableViewBounds: tableView.bounds) {
    case .dynamic:
      return UITableView.automaticDimension
    case .fixed(let value):
      return value
    }
  }
  
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    guard let viewModel = viewModelSections[section].footerViewModel else {
      return 0
    }
    
    let viewModelClass = type(of: viewModel)
    guard let viewClass = _mvvm_registeredViewClassInMapping(forViewModelClass: viewModelClass) else {
      fatalError("Cannot find paired view class for viewModel: \(viewModel)")
    }
    
    guard let viewSizingClass = viewClass as? TableViewReusableViewSizingProtocol.Type else {
      fatalError("\(viewClass) does not conform to \(TableViewReusableViewSizingProtocol.self)")
    }
    
    switch viewSizingClass.tableViewReusableViewHeight(forTableViewBounds: tableView.bounds) {
    case .dynamic:
      return UITableView.automaticDimension
    case .fixed(let value):
      return value
    }
  }
  
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let viewModel = viewModelSections[section].headerViewModel else {
      return nil
    }
    
    let viewModelClass = type(of: viewModel)
    guard let viewClass = _mvvm_registeredViewClassInMapping(forViewModelClass: viewModelClass) else {
      fatalError("Cannot find paired view class for viewModel: \(viewModel)")
    }
    
    let headerView = tableView.dequeueOpaqueReusableHeaderFooterView(type: viewClass.self)
    
    headerView._associatedViewModel = viewModel
    
    return headerView
  }
  
  public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    guard let viewModel = viewModelSections[section].footerViewModel else {
      return nil
    }
    
    let viewModelClass = type(of: viewModel)
    guard let viewClass = _mvvm_registeredViewClassInMapping(forViewModelClass: viewModelClass) else {
      fatalError("Cannot find paired view class for viewModel: \(viewModel)")
    }
    
    let footerView = tableView.dequeueOpaqueReusableHeaderFooterView(type: viewClass.self)
    
    footerView._associatedViewModel = viewModel
    
    return footerView
  }
  
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let viewModel = viewModelSections[indexPath.section].viewModels[indexPath.row]
    
    let viewModelClass = type(of: viewModel)
    guard let viewClass = _mvvm_registeredViewClassInMapping(forViewModelClass: viewModelClass) else {
      fatalError("Cannot find paired view class for viewModel: \(viewModel)")
    }
    
    guard let viewSizingClass = viewClass as? TableViewReusableViewSizingProtocol.Type else {
      fatalError("\(viewClass) does not conform to \(TableViewReusableViewSizingProtocol.self)")
    }
    
    switch viewSizingClass.tableViewReusableViewHeight(forTableViewBounds: tableView.bounds) {
    case .dynamic:
      return UITableView.automaticDimension
    case .fixed(let value):
      return value
    }
  }
  
  public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.row]
    
    return viewModel.shouldHighlight
  }
  
  public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.row]
    
    return viewModel.shouldSelect ? indexPath : nil
  }
  
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.row]
    
    if viewModel.autoDeselect {
      tableView.deselectRow(at: indexPath, animated: true)
    }
    
    if let selectHandler = viewModel.selectHandler {
      let cell = tableView.cellForRow(at: indexPath)!
      selectHandler(viewModel, cell)
    }
  }
  
  public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.row]
    
    if let accessoryTapHandler = viewModel.accessoryTapHandler {
      let cell = tableView.cellForRow(at: indexPath)!
      accessoryTapHandler(viewModel, cell)
    }
  }
  
  public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.row]
    
    return viewModel.editingStyle
  }
  
  public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.row]
    
    if let editingStyleCommittingHandler = viewModel.editingStyleCommittingHandler {
      let cell = tableView.cellForRow(at: indexPath)!
      editingStyleCommittingHandler(viewModel, editingStyle, cell)
    }
  }
  
  public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.row]
    
    return viewModel.leadingSwipeActionsConfiguration
  }
  
  public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.row]
    
    return viewModel.trailingSwipeActionsConfiguration
  }
  
  public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
    let viewModelSection = viewModelSections[proposedDestinationIndexPath.section]
    let viewModel = viewModelSection.viewModels[proposedDestinationIndexPath.row]
    
    return viewModel.canBeMovedTo ? proposedDestinationIndexPath : sourceIndexPath
  }
  
  public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.row]
    
    return viewModel.supportedMenuActions.contains(action)
  }
  
  public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.row]
    
    if let menuActionHandler = viewModel.menuActionHandler {
      let cell = tableView.cellForRow(at: indexPath)!
      menuActionHandler(viewModel, action, cell)
    }
  }

}

// MARK: - ViewModelSectionDelegate
extension TableViewNode: TableViewSectionDelegate {

  public func tableViewSection(_ section: TableViewSection,
                               requestReloadingAtIndices rowIndices: [Int],
                               animated: Bool) {
    let updateBlock = {
      self.tableView.performBatchUpdates({
        guard let sectionIndex = self.viewModelSections.firstIndex(where: { $0 === section }) else {
          fatalError("Cannot find section:\(section) before reloading indices at \(rowIndices)")
        }
        
        let indexPaths = rowIndices.map { IndexPath(row: $0, section: sectionIndex) }
        self.tableView.reloadRows(at: indexPaths, with: .automatic)
      }, completion: nil)
    }
    
    if animated {
      updateBlock()
    } else {
      UIView.performWithoutAnimation {
        updateBlock()
      }
    }
  }
  
  public func tableViewSection(_ section: TableViewSection,
                               requestReloadingWholeSectionWithChange dataChange: @escaping () -> Void,
                               animated: Bool) {
    let updateBlock = {
      self.tableView.performBatchUpdates({
        guard let sectionIndex = self.viewModelSections.firstIndex(where: { $0 === section }) else {
          fatalError("Cannot find section:\(section) before reloading section")
        }
        
        dataChange()
        
        self.tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
      }, completion: nil)
    }
    
    if animated {
      updateBlock()
    } else {
      UIView.performWithoutAnimation {
        updateBlock()
      }
    }

  }
  
  public func tableViewSection(_ section: TableViewSection,
                               requestInsertingAtIndices rowIndices: [Int],
                               dataChange: @escaping () -> Void,
                               animated: Bool) {
    let updateBlock = {
      self.tableView.performBatchUpdates({
        guard let sectionIndex = self.viewModelSections.firstIndex(where: { $0 === section }) else {
          fatalError("Cannot find section:\(section) before inserting indices at \(rowIndices)")
        }
        
        dataChange()
        
        let indexPaths = rowIndices.map { IndexPath(row: $0, section: sectionIndex) }
        self.tableView.insertRows(at: indexPaths, with: .automatic)
      }, completion: nil)
    }
    
    if animated {
      updateBlock()
    } else {
      UIView.performWithoutAnimation {
        updateBlock()
      }
    }
  }
  
  public func tableViewSection(_ section: TableViewSection,
                               requestDeletingAtIndices rowIndices: [Int],
                               dataChange: @escaping () -> Void,
                               animated: Bool) {
    let updateBlock = {
      self.tableView.performBatchUpdates({
        guard let sectionIndex = self.viewModelSections.firstIndex(where: { $0 === section }) else {
          fatalError("Cannot find section:\(section) before inserting indices at \(rowIndices)")
        }
        
        dataChange()
        
        let indexPaths = rowIndices.map { IndexPath(row: $0, section: sectionIndex) }
        self.tableView.deleteRows(at: indexPaths, with: .automatic)
      }, completion: nil)
    }
    
    if animated {
      updateBlock()
    } else {
      UIView.performWithoutAnimation {
        updateBlock()
      }
    }
  }
  
  public func tableViewSection(_ section: TableViewSection,
                               requestUpdatingHeaderWithChange dataChange: @escaping () -> Void,
                               animated: Bool) {
    let updateBlock = {
      self.tableView.performBatchUpdates({
        guard let sectionIndex = self.viewModelSections.firstIndex(where: { $0 === section }) else {
          fatalError("Cannot find section:\(section) before update header at section: \(section)")
        }
        
        dataChange()
        
        self.tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
      }, completion: nil)
    }
    
    if animated {
      updateBlock()
    } else {
      UIView.performWithoutAnimation {
        updateBlock()
      }
    }
  }
  
  public func tableViewSection(_ section: TableViewSection,
                               requestUpdatingFooterWithChange dataChange: @escaping () -> Void,
                               animated: Bool) {
    let updateBlock = {
      self.tableView.performBatchUpdates({
        guard let sectionIndex = self.viewModelSections.firstIndex(where: { $0 === section }) else {
          fatalError("Cannot find section:\(section) before update footer at section: \(section)")
        }
        
        dataChange()
        
        self.tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
      }, completion: nil)
    }
    
    if animated {
      updateBlock()
    } else {
      UIView.performWithoutAnimation {
        updateBlock()
      }
    }
  }
  
  public func tableViewSection(_ section: TableViewSection, requestSelectingRowAt rowIndex: Int, animated: Bool, scrollPosition: UITableView.ScrollPosition) {
    guard let sectionIndex = self.viewModelSections.firstIndex(where: { $0 === section }) else {
      fatalError("Cannot find section:\(section) before update footer at section: \(section)")
    }
    
    self.tableView.selectRow(at: IndexPath(row: rowIndex, section: sectionIndex), animated: animated, scrollPosition: scrollPosition)
  }
  
  public func tableViewSection(_ section: TableViewSection, requestDeselectingRowAt rowIndex: Int, animated: Bool) {
    guard let sectionIndex = self.viewModelSections.firstIndex(where: { $0 === section }) else {
      fatalError("Cannot find section:\(section) before update footer at section: \(section)")
    }
    
    self.tableView.deselectRow(at: IndexPath(row: rowIndex, section: sectionIndex), animated: animated)
  }
  
  public func tableViewSection(_ section: TableViewSection, requestScrollingToRowAt rowIndex: Int, scrollPosition: UITableView.ScrollPosition, animated: Bool) {
    guard let sectionIndex = self.viewModelSections.firstIndex(where: { $0 === section }) else {
      fatalError("Cannot find section:\(section) before scrolling to row at index: \(rowIndex)")
    }
    
    let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
    
    self.tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
  }
  
  public func tableViewSection(_ section: TableViewSection, requestUpdatingTableViewLayoutAnimated animated: Bool) {
    tableView.performBatchUpdates(nil, completion: nil)
  }
  
}

#endif
